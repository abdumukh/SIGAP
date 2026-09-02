<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class LogistikResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id_logistik'   => $this->id_logistik,
            'id_penanganan' => $this->id_penanganan,
            'nama_logistik' => $this->nama_logistik,
            'jumlah'        => $this->jumlah,
            'satuan'        => $this->satuan,
            'kondisi'       => $this->kondisi,
            'note'          => $this->note,
            'penanganan'    => $this->whenLoaded('penanganan', function () {
                return $this->penanganan ? [
                    'id_penanganan'     => $this->penanganan->id_penanganan,
                    'id_alarm'          => $this->penanganan->id_alarm,
                    'id_penugasan'      => $this->penanganan->id_penugasan,
                    'status_penanganan' => $this->penanganan->status_penanganan,
                ] : null;
            }),
            'created_at'    => $this->created_at?->toIso8601String(),
            'updated_at'    => $this->updated_at?->toIso8601String(),
        ];
    }
}
