<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Tests\TestCase;

class DatabaseArchitectureTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();
        config([
            'database.default' => 'pgsql',
            'database.connections.pgsql.database' => 'serviqo',
        ]);
    }

    /**
     * Verify all required domain tables exist in PostgreSQL.
     */
    public function test_all_domain_tables_exist(): void
    {
        $tables = [
            'users',
            'cities',
            'service_categories',
            'customers',
            'technicians',
            'technician_verifications',
            'technician_services',
            'technician_availabilities',
            'service_requests',
            'request_technician_assignments',
            'service_visits',
            'quotations',
            'quotation_items',
            'additional_charges',
            'payments',
            'platform_fees',
            'technician_subscriptions',
            'reviews',
            'complaints',
            'audit_logs',
            'system_settings',
            'personal_access_tokens',
        ];

        foreach ($tables as $table) {
            $this->assertTrue(
                Schema::connection('pgsql')->hasTable($table),
                "Failed asserting that table [{$table}] exists in PostgreSQL."
            );
        }
    }

    /**
     * Verify User model uses UUID primary keys.
     */
    public function test_user_creation_generates_valid_uuid(): void
    {
        $user = User::factory()->create([
            'email' => 'architect_test_' . Str::random(6) . '@serviqo.com',
            'role' => 'customer',
        ]);

        $this->assertNotEmpty($user->id);
        $this->assertTrue(Str::isUuid($user->id), "User primary key [{$user->id}] is not a valid UUID.");

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'role' => 'customer',
        ], 'pgsql');

        $user->forceDelete();
    }

    /**
     * Verify Sanctum tokens table supports UUID tokenables.
     */
    public function test_personal_access_tokens_supports_uuid_tokenables(): void
    {
        $user = User::factory()->create([
            'email' => 'token_test_' . Str::random(6) . '@serviqo.com',
        ]);
        $token = $user->createToken('test-token');

        $this->assertNotEmpty($token->plainTextToken);
        $this->assertDatabaseHas('personal_access_tokens', [
            'tokenable_type' => User::class,
            'tokenable_id' => $user->id,
            'name' => 'test-token',
        ], 'pgsql');

        $user->tokens()->delete();
        $user->forceDelete();
    }

    /**
     * Verify financial column types are numeric/decimal.
     */
    public function test_financial_columns_are_numeric_precision(): void
    {
        $columns = DB::connection('pgsql')->select("
            SELECT table_name, column_name, data_type, numeric_precision, numeric_scale
            FROM information_schema.columns
            WHERE table_schema = 'public'
              AND table_name = 'quotations'
              AND column_name = 'total_amount'
        ");

        $this->assertNotEmpty($columns);
        $this->assertEquals('numeric', $columns[0]->data_type);
        $this->assertEquals(12, $columns[0]->numeric_precision);
        $this->assertEquals(2, $columns[0]->numeric_scale);
    }

    /**
     * Verify review uniqueness per service request constraint (BR-006).
     */
    public function test_reviews_table_has_unique_service_request_constraint(): void
    {
        $constraint = DB::connection('pgsql')->select("
            SELECT constraint_name
            FROM information_schema.table_constraints
            WHERE table_schema = 'public'
              AND table_name = 'reviews'
              AND constraint_type = 'UNIQUE'
        ");

        $this->assertNotEmpty($constraint);
    }
}