<?php

namespace App\Services;

use App\Models\Alarm;
use App\Models\AnggotaTim;
use App\Models\Armada;
use App\Models\Penugasan;
use App\Models\Petugas;
use App\Models\Tim;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class PenugasanService
{
    public function generatePenugasanId(): string
    {
        $latest = Penugasan::orderBy('id_penugasan', 'desc')->first();

        if (!$latest) {
            return 'TGS-001';
        }

        $number = (int) substr($latest->id_penugasan, 4);

        return 'TGS-' . str_pad((string) ($number + 1), 3, '0', STR_PAD_LEFT);
    }

    public function getPenugasanList(): Collection
    {
        return Penugasan::with([
            'alarm',
            'tim',
            'ketuaTim',
            'petugasArmada',
            'armada',
        ])->orderByDesc('waktu_penugasan')->get();
    }

    public function getPenugasanById(string $idPenugasan): ?Penugasan
    {
        return Penugasan::with([
            'alarm',
            'tim',
            'ketuaTim',
            'petugasArmada',
            'armada',
        ])->where('id_penugasan', $idPenugasan)->first();
    }

    public function createPenugasan(array $data): Penugasan
    {
        return DB::transaction(function () use ($data) {
            /** @var Alarm|null $alarm */
            $alarm = Alarm::where('id_alarm', $data['id_alarm'])
                ->lockForUpdate()
                ->first();

            if (!$alarm) {
                throw ValidationException::withMessages([
                    'id_alarm' => ['Alarm tidak ditemukan.'],
                ]);
            }

            if ($alarm->status_alarm !== 'diverifikasi') {
                throw ValidationException::withMessages([
                    'id_alarm' => ['Penugasan hanya dapat dibuat dari alarm yang sudah diverifikasi.'],
                ]);
            }

            $hasActiveAssignment = Penugasan::where('id_alarm', $alarm->id_alarm)
                ->whereNotIn('status_penugasan', ['ditolak', 'selesai'])
                ->exists();

            if ($hasActiveAssignment) {
                throw ValidationException::withMessages([
                    'id_alarm' => ['Alarm tersebut sudah memiliki penugasan aktif.'],
                ]);
            }

            /** @var Tim|null $tim */
            $tim = Tim::where('id_tim', $data['id_tim'])->first();
            if (!$tim) {
                throw ValidationException::withMessages([
                    'id_tim' => ['Tim tidak ditemukan.'],
                ]);
            }

            if ($tim->status_tim !== 'aktif') {
                throw ValidationException::withMessages([
                    'id_tim' => ['Tim yang dipilih tidak aktif.'],
                ]);
            }

            /** @var Petugas|null $ketuaTim */
            $ketuaTim = Petugas::where('id_petugas', $data['id_ketua_tim'])->first();
            if (!$ketuaTim) {
                throw ValidationException::withMessages([
                    'id_ketua_tim' => ['Ketua Tim tidak ditemukan.'],
                ]);
            }

            if ($ketuaTim->role !== 'ketua_tim') {
                throw ValidationException::withMessages([
                    'id_ketua_tim' => ['Petugas yang dipilih bukan Ketua Tim.'],
                ]);
            }

            if ($ketuaTim->status_petugas !== 'aktif') {
                throw ValidationException::withMessages([
                    'id_ketua_tim' => ['Ketua Tim yang dipilih tidak aktif.'],
                ]);
            }

            $ketuaIsMember = AnggotaTim::where('id_tim', $tim->id_tim)
                ->where('id_petugas', $ketuaTim->id_petugas)
                ->where('status_anggota', 'aktif')
                ->exists();

            if (!$ketuaIsMember) {
                throw ValidationException::withMessages([
                    'id_ketua_tim' => ['Ketua Tim harus menjadi anggota aktif dari tim yang dipilih.'],
                ]);
            }

            $idPetugasArmada = $data['id_petugas_armada'] ?? null;
            $idArmada = $data['id_armada'] ?? null;

            if (($idPetugasArmada === null) !== ($idArmada === null)) {
                throw ValidationException::withMessages([
                    'id_armada' => ['id_petugas_armada dan id_armada harus diisi berpasangan.'],
                ]);
            }

            if ($idPetugasArmada !== null) {
                /** @var Petugas|null $petugasArmada */
                $petugasArmada = Petugas::where('id_petugas', $idPetugasArmada)->first();
                if (!$petugasArmada) {
                    throw ValidationException::withMessages([
                        'id_petugas_armada' => ['Petugas armada tidak ditemukan.'],
                    ]);
                }

                if ($petugasArmada->role !== 'petugas') {
                    throw ValidationException::withMessages([
                        'id_petugas_armada' => ['Petugas armada harus memiliki role petugas.'],
                    ]);
                }

                if ($petugasArmada->status_petugas !== 'aktif') {
                    throw ValidationException::withMessages([
                        'id_petugas_armada' => ['Petugas armada yang dipilih tidak aktif.'],
                    ]);
                }

                /** @var Armada|null $armada */
                $armada = Armada::where('id_armada', $idArmada)->lockForUpdate()->first();
                if (!$armada) {
                    throw ValidationException::withMessages([
                        'id_armada' => ['Armada tidak ditemukan.'],
                    ]);
                }

                if ($armada->status_armada !== 'tersedia') {
                    throw ValidationException::withMessages([
                        'id_armada' => ['Armada yang dipilih tidak tersedia.'],
                    ]);
                }

                $petugasIsMember = AnggotaTim::where('id_tim', $tim->id_tim)
                    ->where('id_petugas', $petugasArmada->id_petugas)
                    ->where('status_anggota', 'aktif')
                    ->exists();

                if (!$petugasIsMember) {
                    throw ValidationException::withMessages([
                        'id_petugas_armada' => ['Petugas armada harus menjadi anggota aktif dari tim yang dipilih.'],
                    ]);
                }
            }

            $penugasan = Penugasan::create([
                'id_penugasan'      => $this->generatePenugasanId(),
                'id_alarm'          => $alarm->id_alarm,
                'id_tim'            => $tim->id_tim,
                'id_petugas_armada' => $idPetugasArmada,
                'id_armada'         => $idArmada,
                'id_ketua_tim'      => $ketuaTim->id_petugas,
                'waktu_penugasan'   => $data['waktu_penugasan'] ?? now(),
                'status_penugasan'  => 'menunggu',
                'note'              => $data['note'] ?? null,
            ]);

            if ($idArmada !== null) {
                Armada::where('id_armada', $idArmada)->update(['status_armada' => 'digunakan']);
            }

            return $this->getPenugasanById($penugasan->id_penugasan);
        });
    }
}
