<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreDokumentasiRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'id_penanganan'     => ['required', 'string', 'max:20'],
            'jenis_dokumentasi' => ['required', 'string', 'in:foto,video'],
            'file_dokumentasi'  => ['required'],
            'note'              => ['nullable', 'string', 'max:255'],
        ];
    }
}
