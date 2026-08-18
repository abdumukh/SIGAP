<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateAlarmStatusRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'status_alarm' => ['required', 'string', 'in:diverifikasi,ditolak,selesai'],
        ];
    }

    public function messages(): array
    {
        return [
            'status_alarm.required' => 'Status alarm wajib diisi',
            'status_alarm.in'       => 'Status alarm harus salah satu dari: diverifikasi, ditolak, selesai',
        ];
    }
}
