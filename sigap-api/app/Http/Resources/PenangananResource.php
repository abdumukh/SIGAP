<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PenangananResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id_penanganan'     => $this->id_penanganan,
            'id_alarm'          => $this->id_alarm,
            'id_penugasan'      => $this->id_penugasan,
            'id_petugas'        => $this->id_petugas,
            'waktu_berangkat'   => $this->waktu_berangkat?->toIso8601String(),
            'waktu_tiba'        => $this->waktu_tiba?->toIso8601String(),
            'waktu_selesai'     => $this->waktu_selesai?->toIso8601String(),
            'status_penanganan' => $this->status_penanganan,
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
            'penugasan'         => $this->whenLoaded('penugasan', function () {
                return $this->penugasan ? [
                    'id_penugasan'     => $this->penugasan->id_penugasan,
                    'id_alarm'         => $this->penugasan->id_alarm,
                    'id_tim'           => $this->penugasan->id_tim,
                    'id_ketua_tim'     => $this->penugasan->id_ketua_tim,
                    'status_penugasan' => $this->penugasan->status_penugasan,
                ] : null;
            }),
            'petugas'           => $this->whenLoaded('petugas', function () {
                return $this->petugas ? [
                    'id_petugas'   => $this->petugas->id_petugas,
                    'nama_petugas' => $this->petugas->nama_petugas,
                    'role'         => $this->petugas->role,
                ] : null;
            }),
            'korban'            => $this->whenLoaded('korban', function () {
                return KorbanResource::collection($this->korban);
            }),
            'logistik'          => $this->whenLoaded('logistik', function () {
                return LogistikResource::collection($this->logistik);
            }),
            'created_at'        => $this->created_at?->toIso8601String(),
            'updated_at'        => $this->updated_at?->toIso8601String(),
        ];
    }
}
