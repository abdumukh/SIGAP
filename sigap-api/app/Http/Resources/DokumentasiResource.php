<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DokumentasiResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id_dokumentasi'    => $this->id_dokumentasi,
            'id_penanganan'     => $this->id_penanganan,
            'id_petugas'        => $this->id_petugas,
            'jenis_dokumentasi' => $this->jenis_dokumentasi,
            'file_dokumentasi'  => $this->file_dokumentasi,
            'waktu_upload'      => $this->waktu_upload?->toIso8601String(),
            'note'              => $this->note,
            'penanganan'        => $this->whenLoaded('penanganan', function () {
                return $this->penanganan ? [
                    'id_penanganan'     => $this->penanganan->id_penanganan,
                    'id_alarm'          => $this->penanganan->id_alarm,
                    'id_penugasan'      => $this->penanganan->id_penugasan,
                    'status_penanganan' => $this->penanganan->status_penanganan,
                ] : null;
            }),
            'petugas'           => $this->whenLoaded('petugas', function () {
                return $this->petugas ? [
                    'id_petugas'   => $this->petugas->id_petugas,
                    'nama_petugas' => $this->petugas->nama_petugas,
                    'role'         => $this->petugas->role,
                ] : null;
            }),
            'created_at'        => $this->created_at?->toIso8601String(),
            'updated_at'        => $this->updated_at?->toIso8601String(),
        ];
    }
}
