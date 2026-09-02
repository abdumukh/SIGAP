<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class NotifikasiResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id_notifikasi' => $this->id_notifikasi,
            'type'          => $this->type,
            'title'         => $this->title,
            'message'       => $this->message,
            'data'          => $this->data,
            'read_at'       => $this->read_at,
            'created_at'    => $this->created_at,
            'updated_at'    => $this->updated_at,
            'is_read'       => !is_null($this->read_at),
        ];
    }
}