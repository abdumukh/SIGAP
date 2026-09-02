<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AlarmResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id_alarm'      => $this->id_alarm,
            'id_pengguna'   => $this->id_pengguna,
            'jenis_darurat' => $this->jenis_darurat,
            'waktu_alarm'   => $this->waktu_alarm,
            'latitude'      => (float) $this->latitude,
            'longitude'     => (float) $this->longitude,
            'cuaca'         => $this->cuaca,
            'lalu_lintas'   => $this->lalu_lintas,
            'status_alarm'  => $this->status_alarm,
            'created_at'    => $this->created_at,
            'updated_at'    => $this->updated_at,
            'pengguna'      => $this->whenLoaded('pengguna', function () {
                return [
                    'id_pengguna' => $this->pengguna->id_pengguna,
                    'nama'        => $this->pengguna->nama,
                    'no_hp'       => $this->pengguna->no_hp,
                    'alamat'      => $this->pengguna->alamat,
                    'email'       => $this->pengguna->email,
                ];
            }),
            'penugasan'     => $this->whenLoaded('penugasan', function () {
                return $this->penugasan->map(function ($penugasan) {
                    return [
                        'id_penugasan'      => $penugasan->id_penugasan,
                        'id_alarm'          => $penugasan->id_alarm,
                        'id_tim'            => $penugasan->id_tim,
                        'id_petugas_armada' => $penugasan->id_petugas_armada,
                        'id_armada'         => $penugasan->id_armada,
                        'id_ketua_tim'      => $penugasan->id_ketua_tim,
                        'waktu_penugasan'   => $penugasan->waktu_penugasan?->toIso8601String(),
                        'status_penugasan'  => $penugasan->status_penugasan,
                        'note'              => $penugasan->note,
                        'tim'               => $penugasan->relationLoaded('tim') && $penugasan->tim ? [
                            'id_tim'     => $penugasan->tim->id_tim,
                            'nama_tim'   => $penugasan->tim->nama_tim,
                            'status_tim' => $penugasan->tim->status_tim,
                        ] : null,
                        'ketua_tim'         => $penugasan->relationLoaded('ketuaTim') && $penugasan->ketuaTim ? [
                            'id_petugas'   => $penugasan->ketuaTim->id_petugas,
                            'nama_petugas' => $penugasan->ketuaTim->nama_petugas,
                            'role'         => $penugasan->ketuaTim->role,
                        ] : null,
                        'petugas_armada'    => $penugasan->relationLoaded('petugasArmada') && $penugasan->petugasArmada ? [
                            'id_petugas'   => $penugasan->petugasArmada->id_petugas,
                            'nama_petugas' => $penugasan->petugasArmada->nama_petugas,
                            'role'         => $penugasan->petugasArmada->role,
                        ] : null,
                        'armada'            => $penugasan->relationLoaded('armada') && $penugasan->armada ? [
                            'id_armada'       => $penugasan->armada->id_armada,
                            'nama_armada'     => $penugasan->armada->nama_armada,
                            'jenis_armada'    => $penugasan->armada->jenis_armada,
                            'nomor_kendaraan' => $penugasan->armada->nomor_kendaraan,
                            'status_armada'   => $penugasan->armada->status_armada,
                        ] : null,
                    ];
                });
            }),
            'penanganan'    => $this->whenLoaded('penanganan', function () {
                if (!$this->penanganan) {
                    return null;
                }
                return [
                    'id_penanganan'     => $this->penanganan->id_penanganan,
                    'id_alarm'          => $this->penanganan->id_alarm,
                    'id_penugasan'      => $this->penanganan->id_penugasan,
                    'id_petugas'        => $this->penanganan->id_petugas,
                    'waktu_berangkat'   => $this->penanganan->waktu_berangkat?->toIso8601String(),
                    'waktu_tiba'        => $this->penanganan->waktu_tiba?->toIso8601String(),
                    'waktu_selesai'     => $this->penanganan->waktu_selesai?->toIso8601String(),
                    'status_penanganan' => $this->penanganan->status_penanganan,
                    'note'              => $this->penanganan->note,
                    'petugas'           => $this->penanganan->relationLoaded('petugas') && $this->penanganan->petugas ? [
                        'id_petugas'   => $this->penanganan->petugas->id_petugas,
                        'nama_petugas' => $this->penanganan->petugas->nama_petugas,
                        'role'         => $this->penanganan->petugas->role,
                    ] : null,
                    'dokumentasi_count' => $this->penanganan->dokumentasi()->count(),
                ];
            }),
        ];
    }
}
