<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StorePenugasanRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'id_alarm'          => ['required', 'string', 'max:20'],
            'id_tim'            => ['required', 'string', 'max:20'],
            'id_ketua_tim'      => ['required', 'string', 'max:20'],
            'id_petugas_armada' => ['nullable', 'string', 'max:20'],
            'id_armada'         => ['nullable', 'string', 'max:20'],
            'waktu_penugasan'   => ['nullable', 'date'],
            'note'              => ['nullable', 'string', 'max:255'],
        ];
    }
}
