<?php

namespace Database\Seeders;

use App\Models\City;
use App\Models\Customer;
use App\Models\ServiceCategory;
use App\Models\Technician;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Seed Cities
        $mumbai = City::firstOrCreate(
            ['name' => 'Mumbai', 'state' => 'Maharashtra'],
            [
                'is_active' => true,
                'pincodes' => ['400001', '400050', '400051', '400053', '400076'],
            ]
        );

        $pune = City::firstOrCreate(
            ['name' => 'Pune', 'state' => 'Maharashtra'],
            [
                'is_active' => true,
                'pincodes' => ['411001', '411014', '411028', '411038'],
            ]
        );

        // 2. Seed Service Categories
        $categories = [
            [
                'name' => 'Plumbing',
                'slug' => 'plumbing',
                'description' => 'Pipe leakages, taps, bathroom fixtures, and drainage repair.',
                'min_visiting_charge' => 150.00,
                'max_visiting_charge' => 500.00,
                'sort_order' => 1,
            ],
            [
                'name' => 'Electrical',
                'slug' => 'electrical',
                'description' => 'Short circuits, switchboards, wiring, fan & light installations.',
                'min_visiting_charge' => 150.00,
                'max_visiting_charge' => 600.00,
                'sort_order' => 2,
            ],
            [
                'name' => 'AC Service & Repair',
                'slug' => 'ac-service-repair',
                'description' => 'Split & window AC servicing, gas filling, cooling issue diagnosis.',
                'min_visiting_charge' => 250.00,
                'max_visiting_charge' => 1000.00,
                'sort_order' => 3,
            ],
            [
                'name' => 'Appliance Repair',
                'slug' => 'appliance-repair',
                'description' => 'Refrigerator, washing machine, microwave, and water purifier repairs.',
                'min_visiting_charge' => 200.00,
                'max_visiting_charge' => 800.00,
                'sort_order' => 4,
            ],
            [
                'name' => 'Carpentry',
                'slug' => 'carpentry',
                'description' => 'Furniture repairs, door locks, hinges, and bespoke woodwork.',
                'min_visiting_charge' => 150.00,
                'max_visiting_charge' => 500.00,
                'sort_order' => 5,
            ],
            [
                'name' => 'Painting & Waterproofing',
                'slug' => 'painting-waterproofing',
                'description' => 'Wall painting, touch-ups, seepage control, and ceiling waterproofing.',
                'min_visiting_charge' => 200.00,
                'max_visiting_charge' => 1000.00,
                'sort_order' => 6,
            ],
        ];

        foreach ($categories as $cat) {
            ServiceCategory::firstOrCreate(
                ['slug' => $cat['slug']],
                $cat
            );
        }

        // 3. Super Admin Account
        User::firstOrCreate(
            ['email' => 'admin@serviqo.com'],
            [
                'name' => 'Super Admin',
                'phone' => '9800000001',
                'password' => Hash::make('Admin@123456'),
                'role' => 'admin',
                'is_active' => true,
                'email_verified_at' => now(),
            ]
        );

        // 4. Verified Technician Account
        $techUser = User::firstOrCreate(
            ['email' => 'tech@serviqo.com'],
            [
                'name' => 'Ramesh Sharma',
                'phone' => '9800000002',
                'password' => Hash::make('Tech@123456'),
                'role' => 'technician',
                'is_active' => true,
                'email_verified_at' => now(),
            ]
        );

        Technician::firstOrCreate(
            ['user_id' => $techUser->id],
            [
                'bio' => 'Certified master technician with 8+ years experience in electrical & AC servicing.',
                'experience_years' => 8,
                'visiting_charge' => 250.00,
                'verification_status' => 'verified',
                'verified_at' => now(),
                'is_available' => true,
                'subscription_tier' => 'pro',
                'rating_avg' => 4.85,
                'rating_count' => 42,
                'city_id' => $mumbai->id,
                'address' => 'Andheri West, Mumbai',
                'pincode' => '400053',
            ]
        );

        // 5. Active Customer Account
        $custUser = User::firstOrCreate(
            ['email' => 'customer@serviqo.com'],
            [
                'name' => 'Priya Patel',
                'phone' => '9800000003',
                'password' => Hash::make('Cust@123456'),
                'role' => 'customer',
                'is_active' => true,
                'email_verified_at' => now(),
            ]
        );

        Customer::firstOrCreate(
            ['user_id' => $custUser->id],
            [
                'alternate_phone' => '9800000099',
                'address_line1' => 'Flat 402, Sunshine Heights',
                'address_line2' => 'Bandra West',
                'city_id' => $mumbai->id,
                'pincode' => '400050',
            ]
        );

        // 6. Suspended Account (for security tests)
        User::firstOrCreate(
            ['email' => 'suspended@serviqo.com'],
            [
                'name' => 'Suspended User',
                'phone' => '9800000004',
                'password' => Hash::make('Suspended@123456'),
                'role' => 'customer',
                'is_active' => false,
                'email_verified_at' => now(),
            ]
        );
    }
}