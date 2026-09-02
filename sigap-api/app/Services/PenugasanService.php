<?php

namespace App\Services;

use App\Models\Alarm;
use App\Models\AnggotaTim;
use App\Models\Armada;
use App\Models\Penugasan;
use App\Models\Petugas;
use App\Models\Tim;
use App\Services\NotifikasiService;
use Illuminate\Contracts\Auth\Authenticatable;
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

    public function getPenugasanListForUser(Authenticatable $user): Collection
    {
        $query = Penugasan::with([
            'alarm',
            'tim',
            'ketuaTim',
            'petugasArmada',
            'armada',
        ]);

        $actorService = app(ActorService::class);
        $actor = $actorService->resolveActor($user);

        if ($actor === 'ketua_tim') {
            $query->where(function ($q) use ($user) {
                $q->where('id_ketua_tim', $user->id_petugas)
                    ->orWhereHas('tim.anggotaTim', function ($at) use ($user) {
                        $at->where('id_petugas', $user->id_petugas)
                            ->where('status_anggota', 'aktif');
                    });
            });
        } elseif ($actor === 'petugas') {
            $query->where(function ($q) use ($user) {
                $q->where('id_petugas_armada', $user->id_petugas)
                    ->orWhereHas('tim.anggotaTim', function ($at) use ($user) {
                        $at->where('id_petugas', $user->id_petugas)
                            ->where('status_anggota', 'aktif');
                    });
            });
        }
        // admin: no filter (see all)

        return $query->orderByDesc('waktu_penugasan')->get();
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

            // Notify assigned personnel
            $this->notifyPenugasanCreated($penugasan, $alarm, $ketuaTim, $idPetugasArmada ? $petugasArmada : null);
            // Notify alarm owner
            $this->notifyAlarmOwnerPenugasan($alarm, $penugasan);

            return $this->getPenugasanById($penugasan->id_penugasan);
        });
    }

    public function updatePenugasanStatus(string $idPenugasan, array $data): Penugasan
    {
        return DB::transaction(function () use ($idPenugasan, $data) {
            /** @var Penugasan|null $penugasan */
            $penugasan = Penugasan::where('id_penugasan', $idPenugasan)
                ->lockForUpdate()
                ->first();

            if (!$penugasan) {
                throw ValidationException::withMessages([
                    'id_penugasan' => ['Penugasan tidak ditemukan.'],
                ]);
            }

            $targetStatus = $data['status_penugasan'];
            $currentStatus = $penugasan->status_penugasan;

            $validTransitions = [
                'menunggu'  => ['diterima', 'ditolak'],
                'diterima'  => ['berangkat'],
                'berangkat' => ['selesai'],
                'ditolak'   => [],
                'selesai'   => [],
            ];

            if (!in_array($targetStatus, $validTransitions[$currentStatus] ?? [], true)) {
                throw ValidationException::withMessages([
                    'status_penugasan' => ["Transisi dari '{$currentStatus}' ke '{$targetStatus}' tidak valid."],
                ]);
            }

            $penugasan->status_penugasan = $targetStatus;

            if (array_key_exists('note', $data)) {
                $penugasan->note = $data['note'];
            }

            $penugasan->save();

            if (in_array($targetStatus, ['ditolak', 'selesai']) && $penugasan->id_armada) {
                Armada::where('id_armada', $penugasan->id_armada)
                    ->update(['status_armada' => 'tersedia']);
            }

            return $this->getPenugasanById($penugasan->id_penugasan);
        });
    }

    private function notifyPenugasanCreated(Penugasan $penugasan, Alarm $alarm, Petugas $ketuaTim, ?Petugas $petugasArmada): void
    {
        $notifikasiService = app(NotifikasiService::class);

        $notifikasiService->createNotifikasi(
            $ketuaTim->id_petugas,
            'ketua_tim',
            'PENUGASAN_CREATED',
            'Penugasan Baru',
            "Anda ditugaskan sebagai Ketua Tim untuk laporan {$alarm->jenis_darurat} ({$alarm->id_alarm}).",
            ['id_alarm' => $alarm->id_alarm, 'id_penugasan' => $penugasan->id_penugasan]
        );

        if ($petugasArmada) {
            $notifikasiService->createNotifikasi(
                $petugasArmada->id_petugas,
                'petugas',
                'PENUGASAN_CREATED',
                'Penugasan Baru',
                "Anda ditugaskan sebagai Petugas Armada untuk laporan {$alarm->jenis_darurat} ({$alarm->id_alarm}).",
                ['id_alarm' => $alarm->id_alarm, 'id_penugasan' => $penugasan->id_penugasan]
            );
        }

        // Notify other active team members
        $anggota = \App\Models\AnggotaTim::where('id_tim', $penugasan->id_tim)
            ->where('status_anggota', 'aktif')
            ->where('id_petugas', '!=', $ketuaTim->id_petugas)
            ->when($petugasArmada, fn($q) => $q->where('id_petugas', '!=', $petugasArmada->id_petugas))
            ->get();

        foreach ($anggota as $member) {
            $notifikasiService->createNotifikasi(
                $member->id_petugas,
                'petugas',
                'PENUGASAN_CREATED',
                'Penugasan Baru',
                "Tim Anda ditugaskan untuk laporan {$alarm->jenis_darurat} ({$alarm->id_alarm}).",
                ['id_alarm' => $alarm->id_alarm, 'id_penugasan' => $penugasan->id_penugasan]
            );
        }
    }

    private function notifyAlarmOwnerPenugasan(Alarm $alarm, Penugasan $penugasan): void
    {
        $notifikasiService = app(NotifikasiService::class);

        $notifikasiService->createNotifikasi(
            $alarm->id_pengguna,
            'masyarakat',
            'PENUGASAN_CREATED',
            'Tim Ditugaskan',
            "Laporan {$alarm->jenis_darurat} ({$alarm->id_alarm}) telah ditugaskan ke tim penanganan.",
            ['id_alarm' => $alarm->id_alarm, 'id_penugasan' => $penugasan->id_penugasan]
        );
    }
}
