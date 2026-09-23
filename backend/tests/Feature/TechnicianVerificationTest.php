<?php

namespace Tests\Feature;

use App\Models\AuditLog;
use App\Models\City;
use App\Models\ServiceCategory;
use App\Models\Technician;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class TechnicianVerificationTest extends TestCase
{
    use RefreshDatabase;

    private User $adminUser;
    private User $technicianUser;
    private Technician $technician;
    private User $customerUser;
    private ServiceCategory $acCategory;
    private City $mumbai;

    protected function setUp(): void
    {
        parent::setUp();
        Storage::fake('public');

        $this->mumbai = City::create([
            'name' => 'Mumbai',
            'state' => 'Maharashtra',
            'pincode' => '400001',
            'is_active' => true,
        ]);

        $this->acCategory = ServiceCategory::create([
            'name' => 'AC Repair',
            'slug' => 'ac-repair',
            'min_visiting_charge' => 199.00,
            'is_active' => true,
            'sort_order' => 1,
        ]);

        $this->adminUser = User::create([
            'name' => 'Super Admin',
            'email' => 'admin@example.com',
            'phone' => '9000000001',
            'password' => bcrypt('Admin@123'),
            'role' => 'admin',
            'status' => 'active',
        ]);

        $this->technicianUser = User::create([
            'name' => 'Amit Tech',
            'email' => 'amit@example.com',
            'phone' => '9111223344',
            'password' => bcrypt('Tech@123'),
            'role' => 'technician',
            'status' => 'active',
        ]);

        $this->technician = Technician::create([
            'user_id' => $this->technicianUser->id,
            'city_id' => $this->mumbai->id,
            'experience_years' => 4,
            'visiting_charge' => 150.00,
            'verification_status' => 'pending',
            'is_available' => false,
        ]);

        $this->customerUser = User::create([
            'name' => 'Priya Customer',
            'email' => 'priya@example.com',
            'phone' => '9222334455',
            'password' => bcrypt('Cust@123'),
            'role' => 'customer',
            'status' => 'active',
        ]);
    }

    public function test_technician_can_view_profile(): void
    {
        $token = $this->technicianUser->createToken('test')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->getJson('/api/technician/profile');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'technician' => [
                        'id' => $this->technician->id,
                        'verification_status' => 'pending',
                        'visiting_charge' => '150.00',
                    ],
                ],
            ]);
    }

    public function test_technician_can_update_profile_and_rates(): void
    {
        $token = $this->technicianUser->createToken('test')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->putJson('/api/technician/profile', [
                'name' => 'Amit Sharma Senior',
                'bio' => 'Expert AC and HVAC technician with 6+ years experience.',
                'experience_years' => 6,
                'visiting_charge' => 200.00,
                'address' => 'Shop 4, Linking Road, Bandra',
                'pincode' => '400050',
            ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'user' => [
                        'name' => 'Amit Sharma Senior',
                    ],
                    'technician' => [
                        'experience_years' => 6,
                        'visiting_charge' => '200.00',
                    ],
                ],
            ]);

        $this->assertDatabaseHas('technicians', [
            'id' => $this->technician->id,
            'experience_years' => 6,
            'visiting_charge' => 200.00,
        ]);
    }

    public function test_unverified_technician_cannot_go_available(): void
    {
        $token = $this->technicianUser->createToken('test')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->postJson('/api/technician/availability', [
                'is_available' => true,
            ]);

        $response->assertStatus(422)
            ->assertJson([
                'success' => false,
                'verification_status' => 'pending',
            ]);

        $this->assertDatabaseHas('technicians', [
            'id' => $this->technician->id,
            'is_available' => false,
        ]);
    }

    public function test_technician_can_add_and_remove_service_skill(): void
    {
        $token = $this->technicianUser->createToken('test')->plainTextToken;

        // Add skill
        $response = $this->withHeader('Authorization', "Bearer $token")
            ->postJson('/api/technician/skills', [
                'service_category_id' => $this->acCategory->id,
                'custom_visiting_charge' => 250.00,
                'experience_years' => 5,
            ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'data' => [
                    'service' => [
                        'service_category_id' => $this->acCategory->id,
                        'custom_visiting_charge' => '250.00',
                    ],
                ],
            ]);

        $this->assertDatabaseHas('technician_services', [
            'technician_id' => $this->technician->id,
            'service_category_id' => $this->acCategory->id,
        ]);

        // Remove skill
        $delResponse = $this->withHeader('Authorization', "Bearer $token")
            ->deleteJson('/api/technician/skills/' . $this->acCategory->id);

        $delResponse->assertStatus(200)
            ->assertJson(['success' => true]);

        $this->assertDatabaseMissing('technician_services', [
            'technician_id' => $this->technician->id,
            'service_category_id' => $this->acCategory->id,
        ]);
    }

    public function test_technician_can_upload_verification_document(): void
    {
        $token = $this->technicianUser->createToken('test')->plainTextToken;

        $file = UploadedFile::fake()->create('aadhaar_card.pdf', 500, 'application/pdf');

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->postJson('/api/technician/verifications', [
                'document_type' => 'government_id',
                'document_number' => 'XXXX-XXXX-1234',
                'document' => $file,
            ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'data' => [
                    'verification_status' => 'under_review',
                    'disclaimer' => 'Verified based on submitted and reviewed information.',
                ],
            ]);

        $this->assertDatabaseHas('technician_verifications', [
            'technician_id' => $this->technician->id,
            'document_type' => 'government_id',
            'document_number' => 'XXXX-XXXX-1234',
            'status' => 'pending',
        ]);

        $this->assertDatabaseHas('technicians', [
            'id' => $this->technician->id,
            'verification_status' => 'under_review',
        ]);
    }

    public function test_admin_can_approve_technician_and_audit_log_is_created(): void
    {
        $adminToken = $this->adminUser->createToken('admin')->plainTextToken;

        // Admin approves technician
        $response = $this->withHeader('Authorization', "Bearer $adminToken")
            ->postJson("/api/admin/verifications/{$this->technician->id}/review", [
                'action' => 'approve',
            ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'technician' => [
                        'verification_status' => 'verified',
                        'verified_by' => $this->adminUser->id,
                    ],
                ],
            ]);

        $this->assertDatabaseHas('technicians', [
            'id' => $this->technician->id,
            'verification_status' => 'verified',
            'verified_by' => $this->adminUser->id,
        ]);

        // Verify audit log record
        $this->assertDatabaseHas('audit_logs', [
            'user_id' => $this->adminUser->id,
            'auditable_id' => $this->technician->id,
            'event' => 'technician_verification_approve',
        ]);

        // Verified technician can now toggle availability online!
        $this->app['auth']->forgetGuards();
        $techToken = $this->technicianUser->createToken('test')->plainTextToken;

        $onlineResponse = $this->withHeader('Authorization', "Bearer $techToken")
            ->postJson('/api/technician/availability', [
                'is_available' => true,
            ]);

        $onlineResponse->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'is_available' => true,
                ],
            ]);
    }

    public function test_admin_can_reject_technician_with_reason(): void
    {
        $adminToken = $this->adminUser->createToken('admin')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $adminToken")
            ->postJson("/api/admin/verifications/{$this->technician->id}/review", [
                'action' => 'reject',
                'reason' => 'Government ID document is blurry and unreadable.',
            ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'technician' => [
                        'verification_status' => 'rejected',
                        'verification_notes' => 'Government ID document is blurry and unreadable.',
                    ],
                ],
            ]);

        $this->assertDatabaseHas('technicians', [
            'id' => $this->technician->id,
            'verification_status' => 'rejected',
            'verification_notes' => 'Government ID document is blurry and unreadable.',
        ]);
    }

    public function test_admin_can_suspend_technician_and_availability_is_revoked(): void
    {
        // First verify technician
        $this->technician->update([
            'verification_status' => 'verified',
            'is_available' => true,
        ]);

        $adminToken = $this->adminUser->createToken('admin')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $adminToken")
            ->postJson("/api/admin/verifications/{$this->technician->id}/review", [
                'action' => 'suspend',
                'reason' => 'Multiple serious customer complaints received.',
            ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'technician' => [
                        'verification_status' => 'suspended',
                        'is_available' => false,
                    ],
                ],
            ]);

        $this->assertDatabaseHas('technicians', [
            'id' => $this->technician->id,
            'verification_status' => 'suspended',
            'is_available' => false,
        ]);
    }

    public function test_customer_cannot_access_technician_routes(): void
    {
        $token = $this->customerUser->createToken('test')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->getJson('/api/technician/profile');

        $response->assertStatus(403);
    }
}
