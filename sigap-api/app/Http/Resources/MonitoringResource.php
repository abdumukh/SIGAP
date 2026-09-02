<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MonitoringResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id_alarm'          => $this->id_alarm,
            'jenis_darurat'     => $this->jenis_darurat,
            'waktu_alarm'       => $this->waktu_alarm?->toIso8601String(),
            'latitude'          => (float) $this->latitude,
            'longitude'         => (float) $this->longitude,
            'cuaca'             => $this->cuaca,
            'lalu_lintas'       => $this->lalu_lintas,
            'status_alarm'      => $this->status_alarm,
            'pelapor'           => $this->whenLoaded('pengguna', function () {
                return [
                    'id_pengguna' => $this->pengguna->id_pengguna,
                    'nama'        => $this->pengguna->nama,
                    'no_hp'       => $this->pengguna->no_hp,
                ];
            }),
            'penugasan'         => $this->whenLoaded('penugasan', function () {
                return $this->penugasan->map(function ($p) {
                    return [
                        'id_penugasan'      => $p->id_penugasan,
                        'id_tim'            => $p->id_tim,
                        'nama_tim'          => $p->tim?->nama_tim,
                        'status_penugasan'  => $p->status_penugasan,
                        'waktu_penugasan'   => $p->waktu_penugasan?->toIso8601String(),
                        'ketua_tim'         => $p->ketuaTim ? [
                            'id_petugas'   => $p->ketuaTim->id_petugas,
                            'nama_petugas' => $p->ketuaTim->nama_petugas,
                        ] : null,
                        'petugas_armada'    => $p->petugasArmada ? [
                            'id_petugas'   => $p->petugasArmada->id_petugas,
                            'nama_petugas' => $p->petugasArmada->nama_petugas,
                        ] : null,
                        'armada'            => $p->armada ? [
                            'id_armada'       => $p->armada->id_armada,
                            'nama_armada'     => $p->armada->nama_armada,
                            'nomor_kendaraan' => $p->armada->nomor_kendaraan,
                            'status_armada'   => $p->armada->status_armada,
                        ] : null,
                        'anggota_tim'       => $p->tim && $p->tim->relationLoaded('anggotaTim') ? $p->tim->anggotaTim->map(function ($at) {
                            return [
                                'id_petugas'   => $at->id_petugas,
                                'nama_petugas' => $at->petugas?->nama_petugas,
                                'role_tim'     => $at->role_tim,
                            ];
                        }) : [],
                    ];
                });
            }),
            'penanganan'        => $this->whenLoaded('penanganan', function () {
                if (!$this->penanganan) {
                    return null;
                }
                return [
                    'id_penanganan'     => $this->penanganan->id_penanganan,
                    'status_penanganan' => $this->penanganan->status_penanganan,
                    'waktu_berangkat'   => $this->penanganan->waktu_berangkat?->toIso8601String(),
                    'waktu_tiba'        => $this->penanganan->waktu_tiba?->toIso8601String(),
                    'waktu_selesai'     => $this->penanganan->waktu_selesai?->toIso8601String(),
                    'note'              => $this->penanganan->note,
                    'petugas_handler'   => $this->penanganan->petugas ? [
                        'id_petugas'   => $this->penanganan->petugas->id_petugas,
                        'nama_petugas' => $this->penanganan->petugas->nama_petugas,
                    ] : null,
                    'dokumentasi'       => $this->penanganan->relationLoaded('dokumentasi') ? $this->penanganan->dokumentasi->map(function ($d) {
                        return [
                            'id_dokumentasi'    => $d->id_dokumentasi,
                            'jenis_dokumentasi' => $d->jenis_dokumentasi,
                            'file_dokumentasi'  => $d->file_dokumentasi,
                        ];
                    }) : [],
                    'total_korban'      => $this->penanganan->relationLoaded('korban') ? $this->penanganan->korban->count() : 0,
                    'total_logistik'    => $this->penanganan->relationLoaded('logistik') ? $this->penanganan->logistik->sum('jumlah') : 0,
                ];
            }),
        ];
    }
}
