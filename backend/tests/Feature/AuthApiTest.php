<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\DatabaseTransactions;
use Tests\TestCase;

class AuthApiTest extends TestCase
{
    use DatabaseTransactions;

    public function test_health_endpoint_returns_ok(): void
    {
        $response = $this->getJson('/api/v1/health');

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.version', '1.0.0');
    }

    public function test_user_can_register_fetch_profile_and_logout(): void
    {
        $register = $this->postJson('/api/v1/auth/register', [
            'name' => 'Test Warga',
            'email' => 'testwarga_' . uniqid() . '@nusasiaga.id',
            'password' => 'Password123!',
            'password_confirmation' => 'Password123!',
            'device_name' => 'phpunit',
        ]);

        $register->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.user.role', 'citizen');

        $token = $register->json('data.token');

        $this->withToken($token)
            ->getJson('/api/v1/me')
            ->assertOk()
            ->assertJsonPath('data.user.name', 'Test Warga');

        $this->withToken($token)
            ->postJson('/api/v1/auth/logout')
            ->assertOk()
            ->assertJsonPath('success', true);
    }
}
