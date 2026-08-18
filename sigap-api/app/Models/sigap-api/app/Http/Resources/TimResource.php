<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TimResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id_tim'      => $this->id_tim,
            'nama_tim'    => $this->nama_tim,
            'note'        => $this->note,
            'status_tim'  => $this->status_tim,
            'anggota_tim' => AnggotaTimResource::collection($this->whenLoaded('anggotaTim')),
            'created_at'  => $this->created_at ? $this->created_at->toIso8601String() : null,
            'updated_at'  => $this->updated_at ? $this->updated_at->toIso8601String() : null,
        ];
    }
}
