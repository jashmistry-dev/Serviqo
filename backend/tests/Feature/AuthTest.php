<?php

namespace Tests\Feature;

use App\Models\City;
use App\Models\User;
use Illuminate\Support\Str;
use Tests\TestCase;

class AuthTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();
        config([
            'database.default' => 'pgsql',
            'database.connections.pgsql.database' => 'serviqo',
        ]);
    }

    public function test_customer_can_register_successfully(): void
    {
        $city = City::first();
        $email = 'new_customer_' . Str::random(6) . '@serviqo.com';
        $phone = '98' . rand(10000000, 99999999);

        $response = $this->postJson('/api/auth/register/customer', [
            'name' => 'Aditi Rao',
            'email' => $email,
            'phone' => $phone,
            'password' => 'Password@123',
            'city_id' => $city?->id,
            'address_line1' => '12 MG Road',
            'pincode' => '400001',
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'message',
                'token',
                'user' => ['id', 'name', 'email', 'phone', 'role'],
                'profile' => ['id', 'user_id', 'pincode'],
            ]);

        $this->assertDatabaseHas('users', [
            'email' => strtolower($email),
            'role' => 'customer',
        ], 'pgsql');
    }

    public function test_technician_can_register_successfully(): void
    {
        $city = City::first();
        $email = 'new_tech_' . Str::random(6) . '@serviqo.com';
        $phone = '98' . rand(10000000, 99999999);

        $response = $this->postJson('/api/auth/register/technician', [
            'name' => 'Suresh Kumar',
            'email' => $email,
            'phone' => $phone,
            'password' => 'Password@123',
            'experience_years' => 5,
            'visiting_charge' => 200.00,
            'city_id' => $city?->id,
            'pincode' => '400050',
            'bio' => 'Professional technician with 5 years experience.',
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'message',
                'token',
                'user' => ['id', 'name', 'email', 'phone', 'role'],
                'profile' => ['id', 'user_id', 'visiting_charge', 'verification_status'],
            ]);

        $this->assertDatabaseHas('technicians', [
            'visiting_charge' => '200.00',
            'verification_status' => 'pending',
        ], 'pgsql');
    }

    public function test_cannot_register_with_duplicate_email(): void
    {
        $response = $this->postJson('/api/auth/register/customer', [
            'name' => 'Duplicate Test',
            'email' => 'customer@serviqo.com', // Already seeded
            'phone' => '9899999999',
            'password' => 'Password@123',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['email']);
    }

    public function test_cannot_register_with_short_password(): void
    {
        $response = $this->postJson('/api/auth/register/customer', [
            'name' => 'Short Pass',
            'email' => 'shortpass_' . Str::random(6) . '@serviqo.com',
            'phone' => '98' . rand(10000000, 99999999),
            'password' => '123',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['password']);
    }

    public function test_user_can_login_with_valid_credentials(): void
    {
        $response = $this->postJson('/api/auth/login', [
            'email' => 'customer@serviqo.com',
            'password' => 'Cust@123456',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'message',
                'token',
                'user' => ['id', 'name', 'email', 'role'],
                'profile',
            ]);
    }

    public function test_cannot_login_with_invalid_password(): void
    {
        $response = $this->postJson('/api/auth/login', [
            'email' => 'customer@serviqo.com',
            'password' => 'WrongPassword!',
        ]);

        $response->assertStatus(401)
            ->assertJson(['message' => 'Invalid email or password.']);
    }

    public function test_suspended_user_is_prevented_from_logging_in(): void
    {
        $response = $this->postJson('/api/auth/login', [
            'email' => 'suspended@serviqo.com',
            'password' => 'Suspended@123456',
        ]);

        $response->assertStatus(403)
            ->assertJson(['message' => 'Your account has been deactivated or suspended. Please contact support.']);
    }

    public function test_admin_portal_login_rejects_customer_account(): void
    {
        $response = $this->postJson('/api/auth/login', [
            'email' => 'customer@serviqo.com',
            'password' => 'Cust@123456',
            'expected_role' => 'admin',
        ]);

        $response->assertStatus(403)
            ->assertJson(['message' => "Unauthorized role. This portal requires 'admin' privileges."]);
    }

    public function test_authenticated_user_can_fetch_me_endpoint(): void
    {
        $user = User::where('email', 'customer@serviqo.com')->first();
        $token = $user->createToken('test-me')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer {$token}")
            ->getJson('/api/auth/me');

        $response->assertStatus(200)
            ->assertJsonPath('user.email', 'customer@serviqo.com')
            ->assertJsonStructure(['user', 'profile']);
    }

    public function test_authenticated_user_can_logout(): void
    {
        $user = User::where('email', 'customer@serviqo.com')->first();
        $token = $user->createToken('test-logout')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson('/api/auth/logout');

        $response->assertStatus(200)
            ->assertJson(['message' => 'Logged out successfully.']);
    }

    public function test_role_middleware_enforces_role_boundaries(): void
    {
        $admin = User::where('email', 'admin@serviqo.com')->first();
        $customer = User::where('email', 'customer@serviqo.com')->first();
        $tech = User::where('email', 'tech@serviqo.com')->first();

        $adminToken = $admin->createToken('admin-test')->plainTextToken;
        $customerToken = $customer->createToken('cust-test')->plainTextToken;
        $techToken = $tech->createToken('tech-test')->plainTextToken;

        // Admin ping with Admin token -> 200
        $this->withHeader('Authorization', "Bearer {$adminToken}")
            ->getJson('/api/admin/ping')
            ->assertStatus(200);

        $this->app['auth']->forgetGuards();

        // Admin ping with Customer token -> 403
        $this->withHeader('Authorization', "Bearer {$customerToken}")
            ->getJson('/api/admin/ping')
            ->assertStatus(403);

        $this->app['auth']->forgetGuards();

        // Customer ping with Customer token -> 200
        $this->withHeader('Authorization', "Bearer {$customerToken}")
            ->getJson('/api/customer/ping')
            ->assertStatus(200);

        $this->app['auth']->forgetGuards();

        // Customer ping with Tech token -> 403
        $this->withHeader('Authorization', "Bearer {$techToken}")
            ->getJson('/api/customer/ping')
            ->assertStatus(403);

        $this->app['auth']->forgetGuards();

        // Technician ping with Tech token -> 200
        $this->withHeader('Authorization', "Bearer {$techToken}")
            ->getJson('/api/technician/ping')
            ->assertStatus(200);

        $this->app['auth']->forgetGuards();

        // Technician ping with Customer token -> 403
        $this->withHeader('Authorization', "Bearer {$customerToken}")
            ->getJson('/api/technician/ping')
            ->assertStatus(403);
    }
}