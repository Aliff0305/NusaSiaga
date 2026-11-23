<?php

namespace Database\Seeders;

use App\Models\EmergencyContact;
use App\Models\MitigationGuide;
use App\Models\MitigationStep;
use App\Models\User;
use App\Models\UserAlertPreference;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class NusaSiagaSeeder extends Seeder
{
    public function run(): void
    {
        $demoUsers = [
            [
                'name' => 'Admin NusaSiaga',
                'email' => 'admin@nusasiaga.id',
                'phone' => '081100000001',
                'role' => 'admin',
                'kyc_status' => 'verified',
            ],
            [
                'name' => 'Petugas BPBD Verifikator',
                'email' => 'officer@nusasiaga.id',
                'phone' => '081100000002',
                'role' => 'officer',
                'kyc_status' => 'verified',
            ],
            [
                'name' => 'Relawan Penggagas Kampanye',
                'email' => 'creator@nusasiaga.id',
                'phone' => '081100000003',
                'role' => 'campaign_creator',
                'kyc_status' => 'verified',
            ],
            [
                'name' => 'Warga NusaSiaga',
                'email' => 'citizen@nusasiaga.id',
                'phone' => '081100000004',
                'role' => 'citizen',
                'kyc_status' => 'unverified',
            ],
        ];

        foreach ($demoUsers as $item) {
            $user = User::updateOrCreate(
                ['email' => $item['email']],
                [
                    'name' => $item['name'],
                    'phone' => $item['phone'],
                    'password' => Hash::make('Password123!'),
                    'role' => $item['role'],
                    'kyc_status' => $item['kyc_status'],
                    'is_active' => true,
                    'email_verified_at' => now(),
                ]
            );

            UserAlertPreference::firstOrCreate(
                ['user_id' => $user->id],
                [
                    'enable_earthquake' => true,
                    'min_earthquake_magnitude' => 4.5,
                    'enable_tsunami' => true,
                    'enable_forest_fire' => true,
                    'min_hotspot_confidence' => 'medium',
                    'enable_citizen_reports' => true,
                    'enable_fundraising_updates' => true,
                    'default_radius_km' => 100,
                    'bypass_quiet_for_critical' => true,
                ]
            );
        }

        $guides = [
            [
                'disaster_type' => 'earthquake',
                'phase' => 'during',
                'title' => 'Tindakan Saat Terjadi Gempa Bumi',
                'slug' => 'gempa-bumi-saat-terjadi',
                'summary' => 'Langkah cepat menyelamatkan diri saat guncangan gempa berlangsung.',
                'content' => 'Tetap tenang dan lakukan Drop, Cover, and Hold On hingga guncangan berhenti.',
                'icon_name' => 'earthquake',
                'priority_order' => 1,
                'source_reference' => 'BNPB & BMKG',
                'steps' => [
                    ['step_number' => 1, 'title' => 'Drop, Cover, Hold On', 'instruction' => 'Merunduk, berlindung di bawah meja kokoh, dan berpegangan hingga guncangan berhenti.', 'is_critical_action' => true],
                    ['step_number' => 2, 'title' => 'Jauhi Kaca & Benda Jatuh', 'instruction' => 'Hindari jendela kaca, lemari tinggi, dan lampu gantung.', 'is_critical_action' => true],
                    ['step_number' => 3, 'title' => 'Jangan Gunakan Lift', 'instruction' => 'Gunakan tangga darurat saat evakuasi keluar gedung setelah guncangan mereda.', 'is_critical_action' => false],
                ],
            ],
            [
                'disaster_type' => 'tsunami',
                'phase' => 'during',
                'title' => 'Evakuasi Cepat Peringatan Tsunami',
                'slug' => 'tsunami-saat-peringatan',
                'summary' => 'Segera menjauh dari pantai menuju dataran tinggi saat ada peringatan tsunami.',
                'content' => 'Jangan menunggu melihat gelombang. Gempa kuat di pesisir adalah peringatan alami.',
                'icon_name' => 'tsunami',
                'priority_order' => 1,
                'source_reference' => 'BMKG InaTEWS & BNPB',
                'steps' => [
                    ['step_number' => 1, 'title' => 'Menuju Dataran Tinggi (>30m)', 'instruction' => 'Segera lari atau evakuasi ke bukit atau gedung evakuasi vertikal minimal 30 meter di atas permukaan laut.', 'is_critical_action' => true],
                    ['step_number' => 2, 'title' => 'Ikuti Jalur Evakuasi Resmi', 'instruction' => 'Ikuti rambu jalur evakuasi tsunami dan jauhi sungai atau muara.', 'is_critical_action' => true],
                ],
            ],
            [
                'disaster_type' => 'forest_fire',
                'phase' => 'during',
                'title' => 'Perlindungan Diri Saat Kebakaran Hutan & Kabut Asap',
                'slug' => 'karhutla-saat-kabut-asap',
                'summary' => 'Lindungi pernapasan dari asap pekat dan segera laporkan titik api aktif.',
                'content' => 'Kurangi aktivitas luar ruangan, gunakan masker N95, dan pantau arah angin.',
                'icon_name' => 'forest_fire',
                'priority_order' => 1,
                'source_reference' => 'KLHK & Kemenkes RI',
                'steps' => [
                    ['step_number' => 1, 'title' => 'Gunakan Masker N95/KN95', 'instruction' => 'Lindungi saluran pernapasan dari partikel halus PM2.5.', 'is_critical_action' => true],
                    ['step_number' => 2, 'title' => 'Tutup Ventilasi Rumah', 'instruction' => 'Tutup rapat jendela dan celah pintu menggunakan kain basah jika asap pekat.', 'is_critical_action' => false],
                ],
            ],
        ];

        foreach ($guides as $g) {
            $steps = $g['steps'];
            unset($g['steps']);

            $guide = MitigationGuide::updateOrCreate(
                ['slug' => $g['slug']],
                array_merge($g, ['is_published' => true])
            );

            foreach ($steps as $s) {
                MitigationStep::updateOrCreate(
                    ['mitigation_guide_id' => $guide->id, 'step_number' => $s['step_number']],
                    $s
                );
            }
        }

        $contacts = [
            ['name' => 'Pusdalops BNPB Nasional', 'agency' => 'BNPB', 'phone_number' => '117', 'disaster_scope' => 'all', 'is_national' => true, 'sort_order' => 1, 'description' => 'Call center darurat bencana nasional 24 jam'],
            ['name' => 'BASARNAS (SAR Nasional)', 'agency' => 'BASARNAS', 'phone_number' => '115', 'disaster_scope' => 'all', 'is_national' => true, 'sort_order' => 2, 'description' => 'Layanan pencarian dan pertolongan darurat'],
            ['name' => 'Pemadam Kebakaran', 'agency' => 'DAMKAR', 'phone_number' => '113', 'disaster_scope' => 'forest_fire', 'is_national' => true, 'sort_order' => 3, 'description' => 'Layanan darurat pemadaman kebakaran'],
            ['name' => 'Ambulans & Gawat Darurat Medis', 'agency' => 'KEMENKES', 'phone_number' => '119', 'disaster_scope' => 'all', 'is_national' => true, 'sort_order' => 4, 'description' => 'Layanan medis darurat nasional'],
        ];

        foreach ($contacts as $c) {
            EmergencyContact::updateOrCreate(
                ['phone_number' => $c['phone_number'], 'agency' => $c['agency']],
                array_merge($c, ['is_active' => true])
            );
        }
    }
}
