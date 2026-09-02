<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreLogistikRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'id_penanganan' => ['required', 'string', 'max:20'],
            'nama_logistik' => ['required', 'string', 'max:75'],
            'jumlah'        => ['required', 'integer', 'min:1'],
            'satuan'        => ['required', 'string', 'max:20'],
            'kondisi'       => ['required', 'string', 'max:30'],
            'note'          => ['nullable', 'string', 'max:255'],
        ];
    }
}