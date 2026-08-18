<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AnggotaTimResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id_anggota_tim' => $this->id_anggota_tim,
            'id_tim'         => $this->id_tim,
            'id_petugas'     => $this->id_petugas,
            'tanggal_masuk'  => $this->tanggal_masuk
                ? ($this->tanggal_masuk instanceof \DateTimeInterface
                    ? $this->tanggal_masuk->format('Y-m-d')
                    : (string) $this->tanggal_masuk)
                : null,
            'status_anggota' => $this->status_anggota,
            'petugas'        => $this->whenLoaded('petugas', function () {
                return [
                    'id_petugas'     => $this->petugas->id_petugas,
                    'nama_petugas'   => $this->petugas->nama_petugas,
                    'no_hp'          => $this->petugas->no_hp,
                    'email'          => $this->petugas->email,
                    'alamat'         => $this->petugas->alamat,
                    'status_petugas' => $this->petugas->status_petugas,
                    'role'           => $this->petugas->role,
                ];
            }),
            'created_at'     => $this->created_at ? $this->created_at->toIso8601String() : null,
            'updated_at'     => $this->updated_at ? $this->updated_at->toIso8601String() : null,
        ];
    }
}
