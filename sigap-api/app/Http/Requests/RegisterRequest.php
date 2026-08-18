<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'nama'     => ['required', 'string', 'max:75'],
            'no_hp'    => ['required', 'string', 'max:15'],
            'alamat'   => ['required', 'string', 'max:255'],
            'email'    => ['required', 'string', 'email', 'max:100', 'unique:pengguna,email'],
            'password' => ['required', 'string', 'min:6', 'confirmed'],
        ];
    }
}
