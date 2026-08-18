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
        ];
    }
}
