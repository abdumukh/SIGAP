<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateTimRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'nama_tim'   => 'sometimes|required|string|max:50',
            'note'       => 'nullable|string|max:255',
            'status_tim' => 'sometimes|required|string|in:aktif,nonaktif',
        ];
    }
}
