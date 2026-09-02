<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdatePenugasanRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'status_penugasan' => ['required', 'string', 'in:diterima,ditolak,berangkat,selesai'],
            'note'             => ['nullable', 'string', 'max:255'],
        ];
    }
}
