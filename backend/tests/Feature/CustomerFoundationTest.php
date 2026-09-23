<?php

namespace Tests\Feature;

use App\Models\City;
use App\Models\Customer;
use App\Models\ServiceCategory;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CustomerFoundationTest extends TestCase
{
    use RefreshDatabase;

    private User $customerUser;
    private User $technicianUser;
    private City $mumbai;
    private City $pune;
    private ServiceCategory $acCategory;
    private ServiceCategory $plumbingCategory;

    protected function setUp(): void
    {
        parent::setUp();

        $this->mumbai = City::create([
            'name' => 'Mumbai',
            'state' => 'Maharashtra',
            'pincode' => '400001',
            'is_active' => true,
        ]);

        $this->pune = City::create([
            'name' => 'Pune',
            'state' => 'Maharashtra',
            'pincode' => '411001',
            'is_active' => true,
        ]);

        $this->acCategory = ServiceCategory::create([
            'name' => 'Air Conditioner Repair',
            'slug' => 'ac-repair',
            'description' => 'Cooling and repair services',
            'min_visiting_charge' => 199.00,
            'is_active' => true,
            'sort_order' => 1,
        ]);

        $this->plumbingCategory = ServiceCategory::create([
            'name' => 'Plumbing Services',
            'slug' => 'plumbing',
            'description' => 'Pipes, taps, and sanitary work',
            'min_visiting_charge' => 149.00,
            'is_active' => true,
            'sort_order' => 2,
        ]);

        $this->customerUser = User::create([
            'name' => 'Kavita Verma',
            'email' => 'kavita@example.com',
            'phone' => '9822334455',
            'password' => bcrypt('Password@123'),
            'role' => 'customer',
            'status' => 'active',
        ]);

        Customer::create([
            'user_id' => $this->customerUser->id,
            'city_id' => $this->mumbai->id,
            'address_line1' => 'Flat 402, Sunshine Towers',
            'address_line2' => 'Andheri West',
            'pincode' => '400053',
            'latitude' => 19.1136,
            'longitude' => 72.8697,
        ]);

        $this->technicianUser = User::create([
            'name' => 'Sunil Kumar',
            'email' => 'sunil@example.com',
            'phone' => '9833445566',
            'password' => bcrypt('Password@123'),
            'role' => 'technician',
            'status' => 'active',
        ]);
    }

    public function test_can_list_active_service_categories_in_order(): void
    {
        $response = $this->getJson('/api/categories');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ])
            ->assertJsonCount(2, 'data.categories')
            ->assertJsonPath('data.categories.0.slug', 'ac-repair')
            ->assertJsonPath('data.categories.1.slug', 'plumbing');
    }

    public function test_can_view_category_detail_by_slug(): void
    {
        $response = $this->getJson('/api/categories/ac-repair');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'category' => [
                        'name' => 'Air Conditioner Repair',
                        'slug' => 'ac-repair',
                        'min_visiting_charge' => '199.00',
                    ],
                ],
            ]);
    }

    public function test_returns_404_for_unknown_category(): void
    {
        $response = $this->getJson('/api/categories/non-existent-category');

        $response->assertStatus(404)
            ->assertJson([
                'success' => false,
            ]);
    }

    public function test_can_list_active_cities(): void
    {
        $response = $this->getJson('/api/cities');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ])
            ->assertJsonCount(2, 'data.cities');
    }

    public function test_customer_can_view_profile(): void
    {
        $token = $this->customerUser->createToken('test')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->getJson('/api/customer/profile');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'user' => [
                        'id' => $this->customerUser->id,
                        'name' => 'Kavita Verma',
                        'email' => 'kavita@example.com',
                        'role' => 'customer',
                    ],
                    'customer' => [
                        'address_line1' => 'Flat 402, Sunshine Towers',
                        'address_line2' => 'Andheri West',
                        'pincode' => '400053',
                    ],
                ],
            ]);
    }

    public function test_customer_can_update_profile_and_address(): void
    {
        $token = $this->customerUser->createToken('test')->plainTextToken;

        $updateData = [
            'name' => 'Kavita Sharma',
            'phone' => '9899887766',
            'alternate_phone' => '9811223344',
            'city_id' => $this->pune->id,
            'address_line1' => 'A-101, Blue Ridge',
            'address_line2' => 'Hinjewadi Phase 1',
            'pincode' => '411057',
            'latitude' => 18.5912,
            'longitude' => 73.7389,
        ];

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->putJson('/api/customer/profile', $updateData);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Customer profile updated successfully',
                'data' => [
                    'user' => [
                        'name' => 'Kavita Sharma',
                        'phone' => '9899887766',
                    ],
                    'customer' => [
                        'city_id' => $this->pune->id,
                        'address_line1' => 'A-101, Blue Ridge',
                        'pincode' => '411057',
                    ],
                ],
            ]);

        $this->assertDatabaseHas('users', [
            'id' => $this->customerUser->id,
            'name' => 'Kavita Sharma',
            'phone' => '9899887766',
        ]);

        $this->assertDatabaseHas('customers', [
            'user_id' => $this->customerUser->id,
            'city_id' => $this->pune->id,
            'address_line1' => 'A-101, Blue Ridge',
            'pincode' => '411057',
        ]);
    }

    public function test_customer_cannot_update_with_duplicate_phone(): void
    {
        $token = $this->customerUser->createToken('test')->plainTextToken;

        // Try to take the technician's phone number
        $response = $this->withHeader('Authorization', "Bearer $token")
            ->putJson('/api/customer/profile', [
                'phone' => $this->technicianUser->phone,
            ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['phone']);
    }

    public function test_technician_cannot_access_customer_profile_endpoints(): void
    {
        $token = $this->technicianUser->createToken('test')->plainTextToken;

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->getJson('/api/customer/profile');

        $response->assertStatus(403);

        $response = $this->withHeader('Authorization', "Bearer $token")
            ->putJson('/api/customer/profile', [
                'name' => 'Hacked Name',
            ]);

        $response->assertStatus(403);
    }

    public function test_unauthenticated_cannot_access_customer_profile(): void
    {
        $response = $this->getJson('/api/customer/profile');
        $response->assertStatus(401);
    }
}
