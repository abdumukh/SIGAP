<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreKorbanRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'id_penanganan'     => ['required', 'string', 'max:20'],
            'nama_korban'       => ['required', 'string', 'max:75'],
            'jenis_kelamin'     => ['required', 'string', 'in:L,P'],
            'usia'              => ['required', 'integer', 'min:0', 'max:150'],
            'kondisi'           => ['required', 'string', 'max:50'],
            'status_penanganan' => ['required', 'string', 'max:50'],
            'note'              => ['nullable', 'string', 'max:255'],
        ];
    }
}
