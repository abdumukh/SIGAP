<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StorePenangananRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'id_penugasan' => ['required', 'string', 'max:20'],
            'note'         => ['nullable', 'string', 'max:255'],
        ];
    }
}
