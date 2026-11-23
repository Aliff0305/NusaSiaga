<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Auth\LoginRequest;
use App\Http\Requests\Api\V1\Auth\RegisterRequest;
use App\Models\User;
use App\Models\UserAlertPreference;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Symfony\Component\HttpFoundation\Response;

class AuthController extends Controller
{
    use ApiResponse;

    public function register(RegisterRequest $request): JsonResponse
    {
        $user = User::create([
            'name' => $request->string('name')->toString(),
            'email' => $request->string('email')->toString(),
            'phone' => $request->input('phone'),
            'password' => $request->string('password')->toString(),
            'role' => 'citizen',
            'kyc_status' => 'unverified',
            'is_active' => true,
        ]);

        UserAlertPreference::create([
            'user_id' => $user->id,
            'enable_earthquake' => true,
            'min_earthquake_magnitude' => 4.5,
            'enable_tsunami' => true,
            'enable_forest_fire' => true,
            'min_hotspot_confidence' => 'medium',
            'enable_citizen_reports' => true,
            'enable_fundraising_updates' => true,
            'default_radius_km' => 100,
            'bypass_quiet_for_critical' => true,
        ]);

        $token = $user->createToken($request->input('device_name', 'mobile-app'))->plainTextToken;

        return $this->success([
            'user' => $user,
            'token' => $token,
            'token_type' => 'Bearer',
        ], 'Registrasi berhasil.', Response::HTTP_CREATED);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $user = User::where('email', $request->string('email')->toString())->first();

        if (! $user || ! Hash::check($request->string('password')->toString(), $user->password)) {
            return $this->error('Email atau kata sandi tidak valid.', Response::HTTP_UNAUTHORIZED);
        }

        if (! $user->is_active) {
            return $this->error('Akun Anda sedang dinonaktifkan.', Response::HTTP_FORBIDDEN);
        }

        $token = $user->createToken($request->input('device_name', 'mobile-app'))->plainTextToken;

        return $this->success([
            'user' => $user,
            'token' => $token,
            'token_type' => 'Bearer',
        ], 'Login berhasil.');
    }

    public function me(Request $request): JsonResponse
    {
        return $this->success([
            'user' => $request->user()->load('alertPreference'),
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()?->delete();

        return $this->success(null, 'Logout berhasil.');
    }
}
