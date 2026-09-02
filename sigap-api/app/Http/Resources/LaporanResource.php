<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class LaporanResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $type = $this->resource['type'] ?? 'unknown';
        $items = $this->resource['items'] ?? [];

        if ($type === 'alarm') {
            return $this->formatAlarmItems($items);
        }

        if ($type === 'penugasan') {
            return $this->formatPenugasanItems($items);
        }

        if ($type === 'penanganan') {
            return $this->formatPenangananItems($items);
        }

        if ($type === 'pengguna') {
            return $this->formatPenggunaItems($items);
        }

        if ($type === 'petugas') {
            return $this->formatPetugasItems($items);
        }

        return [
            'type'  => $type,
            'total' => $this->resource['total'] ?? 0,
            'items' => [],
        ];
    }

    private function formatAlarmItems($items): array
    {
        return [
            'type'  => 'alarm',
            'total' => $this->resource['total'] ?? 0,
            'items' => $items->map(function ($item) {
                return [
                    'id_alarm'      => $item->id_alarm,
                    'id_pengguna'   => $item->id_pengguna,
                    'jenis_darurat' => $item->jenis_darurat,
                    'waktu_alarm'   => $item->waktu_alarm?->toIso8601String(),
                    'latitude'      => (float) $item->latitude,
                    'longitude'     => (float) $item->longitude,
                    'status_alarm'  => $item->status_alarm,
                    'pelapor'       => $item->relationLoaded('pengguna') && $item->pengguna ? [
                        'id_pengguna' => $item->pengguna->id_pengguna,
                        'nama'        => $item->pengguna->nama,
                        'no_hp'       => $item->pengguna->no_hp,
                    ] : null,
                ];
            }),
        ];
    }

    private function formatPenugasanItems($items): array
    {
        return [
            'type'  => 'penugasan',
            'total' => $this->resource['total'] ?? 0,
            'items' => $items->map(function ($item) {
                return [
                    'id_penugasan'      => $item->id_penugasan,
                    'id_alarm'          => $item->id_alarm,
                    'id_tim'            => $item->id_tim,
                    'id_ketua_tim'      => $item->id_ketua_tim,
                    'id_petugas_armada' => $item->id_petugas_armada,
                    'id_armada'         => $item->id_armada,
                    'waktu_penugasan'   => $item->waktu_penugasan?->toIso8601String(),
                    'status_penugasan'  => $item->status_penugasan,
                    'note'              => $item->note,
                    'alarm'             => $item->relationLoaded('alarm') && $item->alarm ? [
                        'id_alarm'      => $item->alarm->id_alarm,
                        'jenis_darurat' => $item->alarm->jenis_darurat,
                    ] : null,
                    'tim'               => $item->relationLoaded('tim') && $item->tim ? [
                        'id_tim'   => $item->tim->id_tim,
                        'nama_tim' => $item->tim->nama_tim,
                    ] : null,
                    'ketua_tim'         => $item->relationLoaded('ketuaTim') && $item->ketuaTim ? [
                        'id_petugas'   => $item->ketuaTim->id_petugas,
                        'nama_petugas' => $item->ketuaTim->nama_petugas,
                    ] : null,
                    'petugas_armada'    => $item->relationLoaded('petugasArmada') && $item->petugasArmada ? [
                        'id_petugas'   => $item->petugasArmada->id_petugas,
                        'nama_petugas' => $item->petugasArmada->nama_petugas,
                    ] : null,
                    'armada'            => $item->relationLoaded('armada') && $item->armada ? [
                        'id_armada'       => $item->armada->id_armada,
                        'nama_armada'     => $item->armada->nama_armada,
                        'nomor_kendaraan' => $item->armada->nomor_kendaraan,
                    ] : null,
                ];
            }),
        ];
    }

    private function formatPenangananItems($items): array
    {
        return [
            'type'  => 'penanganan',
            'total' => $this->resource['total'] ?? 0,
            'items' => $items->map(function ($item) {
                return [
                    'id_penanganan'     => $item->id_penanganan,
                    'id_alarm'          => $item->id_alarm,
                    'id_penugasan'      => $item->id_penugasan,
                    'id_petugas'        => $item->id_petugas,
                    'waktu_berangkat'   => $item->waktu_berangkat?->toIso8601String(),
                    'waktu_tiba'        => $item->waktu_tiba?->toIso8601String(),
                    'waktu_selesai'     => $item->waktu_selesai?->toIso8601String(),
                    'status_penanganan' => $item->status_penanganan,
                    'note'              => $item->note,
                    'alarm'             => $item->relationLoaded('alarm') && $item->alarm ? [
                        'id_alarm'      => $item->alarm->id_alarm,
                        'jenis_darurat' => $item->alarm->jenis_darurat,
                    ] : null,
                    'penugasan'         => $item->relationLoaded('penugasan') && $item->penugasan ? [
                        'id_penugasan' => $item->penugasan->id_penugasan,
                        'id_tim'       => $item->penugasan->id_tim,
                    ] : null,
                    'petugas'           => $item->relationLoaded('petugas') && $item->petugas ? [
                        'id_petugas'   => $item->petugas->id_petugas,
                        'nama_petugas' => $item->petugas->nama_petugas,
                    ] : null,
                    'total_dokumentasi' => $item->relationLoaded('dokumentasi') ? $item->dokumentasi->count() : 0,
                    'total_korban'      => $item->relationLoaded('korban') ? $item->korban->count() : 0,
                    'total_logistik'    => $item->relationLoaded('logistik') ? $item->logistik->sum('jumlah') : 0,
                ];
            }),
        ];
    }

    private function formatPenggunaItems($items): array
    {
        return [
            'type'  => 'pengguna',
            'total' => $this->resource['total'] ?? 0,
            'items' => $items->map(function ($item) {
                return [
                    'id_pengguna' => $item->id_pengguna,
                    'nama'        => $item->nama,
                    'email'       => $item->email,
                    'no_hp'       => $item->no_hp,
                    'alamat'      => $item->alamat,
                ];
            }),
        ];
    }

    private function formatPetugasItems($items): array
    {
        return [
            'type'  => 'petugas',
            'total' => $this->resource['total'] ?? 0,
            'items' => $items->map(function ($item) {
                return [
                    'id_petugas'    => $item->id_petugas,
                    'nama_petugas'  => $item->nama_petugas,
                    'email'         => $item->email,
                    'no_hp'         => $item->no_hp,
                    'status_petugas'=> $item->status_petugas,
                    'role'          => $item->role,
                    'tim'           => $item->relationLoaded('anggotaTim') ? $item->anggotaTim->map(function ($at) {
                        return [
                            'id_tim'   => $at->id_tim,
                            'nama_tim' => $at->tim?->nama_tim,
                        ];
                    }) : [],
                ];
            }),
        ];
    }
}