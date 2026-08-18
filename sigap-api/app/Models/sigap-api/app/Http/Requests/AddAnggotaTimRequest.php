<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class AddAnggotaTimRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'id_petugas'     => 'required|string|exists:petugas,id_petugas',
            'tanggal_masuk'  => 'nullable|date',
            'status_anggota' => 'nullable|string|in:aktif,nonaktif',
        ];
    }
}
