<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreAlarmRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'jenis_darurat' => ['required', 'string', 'max:30'],
            'latitude'      => ['required', 'numeric', 'between:-90,90'],
            'longitude'     => ['required', 'numeric', 'between:-180,180'],
            'cuaca'         => ['nullable', 'string', 'max:50'],
            'lalu_lintas'   => ['nullable', 'string', 'max:50'],
            'waktu_alarm'   => ['nullable', 'date'],
        ];
    }

    public function messages(): array
    {
        return [
            'jenis_darurat.required' => 'Jenis darurat wajib diisi',
            'latitude.required'      => 'Koordinat latitude wajib diisi',
            'longitude.required'     => 'Koordinat longitude wajib diisi',
        ];
    }
}
