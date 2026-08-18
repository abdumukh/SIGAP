<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdatePenangananRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'status_penanganan' => ['required', 'string', 'in:menuju_lokasi,di_lokasi,selesai'],
            'note'              => ['nullable', 'string', 'max:255'],
        ];
    }
}
