<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PenugasanResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id_penugasan'      => $this->id_penugasan,
            'id_alarm'          => $this->id_alarm,
            'id_tim'            => $this->id_tim,
            'id_petugas_armada' => $this->id_petugas_armada,
            'id_armada'         => $this->id_armada,
            'id_ketua_tim'      => $this->id_ketua_tim,
            'waktu_penugasan'   => $this->waktu_penugasan?->toIso8601String(),
            'status_penugasan'  => $this->status_penugasan,
            'note'              => $this->note,
            'alarm'             => $this->whenLoaded('alarm', function () {
                return $this->alarm ? [
                    'id_alarm'      => $this->alarm->id_alarm,
                    'jenis_darurat' => $this->alarm->jenis_darurat,
                    'waktu_alarm'   => $this->alarm->waktu_alarm?->toIso8601String(),
                    'latitude'      => $this->alarm->latitude,
                    'longitude'     => $this->alarm->longitude,
                    'status_alarm'  => $this->alarm->status_alarm,
                ] : null;
            }),
            'tim'               => $this->whenLoaded('tim', function () {
                return $this->tim ? [
                    'id_tim'     => $this->tim->id_tim,
                    'nama_tim'   => $this->tim->nama_tim,
                    'status_tim' => $this->tim->status_tim,
                ] : null;
            }),
            'ketua_tim'         => $this->whenLoaded('ketuaTim', function () {
                return $this->ketuaTim ? [
                    'id_petugas'   => $this->ketuaTim->id_petugas,
                    'nama_petugas' => $this->ketuaTim->nama_petugas,
                    'role'         => $this->ketuaTim->role,
                ] : null;
            }),
            'petugas_armada'    => $this->whenLoaded('petugasArmada', function () {
                return $this->petugasArmada ? [
                    'id_petugas'   => $this->petugasArmada->id_petugas,
                    'nama_petugas' => $this->petugasArmada->nama_petugas,
                    'role'         => $this->petugasArmada->role,
                ] : null;
            }),
            'armada'            => $this->whenLoaded('armada', function () {
                return $this->armada ? [
                    'id_armada'       => $this->armada->id_armada,
                    'nama_armada'     => $this->armada->nama_armada,
                    'jenis_armada'    => $this->armada->jenis_armada,
                    'nomor_kendaraan' => $this->armada->nomor_kendaraan,
                    'status_armada'   => $this->armada->status_armada,
                ] : null;
            }),
            'created_at'        => $this->created_at?->toIso8601String(),
            'updated_at'        => $this->updated_at?->toIso8601String(),
        ];
    }
}
