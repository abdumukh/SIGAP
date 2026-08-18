<?php

namespace App\Services;

use App\Models\Tim;
use Illuminate\Database\Eloquent\Collection;

class TimService
{
    /**
     * Generate custom unique ID for Tim (TIM-001, TIM-002, etc.)
     */
    public function generateTimId(): string
    {
        $latest = Tim::orderBy('id_tim', 'desc')->first();

        if (!$latest) {
            return 'TIM-001';
        }

        $number = (int) substr($latest->id_tim, 4);
        $nextNumber = $number + 1;

        return 'TIM-' . str_pad((string) $nextNumber, 3, '0', STR_PAD_LEFT);
    }

    /**
     * Retrieve all teams with members.
     */
    public function getTimList(): Collection
    {
        return Tim::with(['anggotaTim.petugas'])->orderBy('id_tim', 'asc')->get();
    }

    /**
     * Retrieve single team by ID.
     */
    public function getTimById(string $idTim): ?Tim
    {
        return Tim::where('id_tim', $idTim)->with(['anggotaTim.petugas'])->first();
    }

    /**
     * Create new Team.
     */
    public function createTim(array $data): Tim
    {
        $tim = new Tim();
        $tim->id_tim     = $this->generateTimId();
        $tim->nama_tim   = $data['nama_tim'];
        $tim->note       = $data['note'] ?? null;
        $tim->status_tim = $data['status_tim'] ?? 'aktif';
        $tim->save();

        return $tim;
    }

    /**
     * Update existing Team.
     */
    public function updateTim(Tim $tim, array $data): Tim
    {
        if (isset($data['nama_tim'])) {
            $tim->nama_tim = $data['nama_tim'];
        }
        if (array_key_exists('note', $data)) {
            $tim->note = $data['note'];
        }
        if (isset($data['status_tim'])) {
            $tim->status_tim = $data['status_tim'];
        }

        $tim->save();

        return $tim;
    }

    /**
     * Deactivate / Delete Team based on business rules.
     */
    public function deleteTim(Tim $tim): bool
    {
        // Deactivate status to preserve audit trail
        $tim->status_tim = 'nonaktif';
        return $tim->save();
    }
}
