<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreTimRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'nama_tim'   => 'required|string|max:50',
            'note'       => 'nullable|string|max:255',
            'status_tim' => 'nullable|string|in:aktif,nonaktif',
        ];
    }
}
