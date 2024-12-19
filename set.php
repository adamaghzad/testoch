<?php

require 'connection.php'; // Ensure you have a secure connection file

try {
    // Perform a JOIN and select all required fields except user_id
    $stmt = $pdo->prepare('
        SELECT
            u.username,
            r.data_inizio_turno,
            r.inizio_turno,
            r.targa_furgone,
            r.swap_ebike,
            r.swap_lite,
            r.relocation,
            r.repacking,
            r.short_fix,
            r.fix,
            r.swap_relocation,
            r.fix_swap,
            r.fix_relocation,
            r.fix_swap_relocation,
            r.pick_up,
            r.missing,
            r.deployment,
            r.ore_ricarica_armadio,
            r.ore_fuori_area,
            r.ore_app_lenta,
            r.ore_segnalazioni_ritiri,
            r.km_furgone_a_fine_turno,
            r.note
        FROM reports r
        JOIN users u ON r.user_id = u.user_id
    ');

    $stmt->execute();
    $reports = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Format the date field if it exists
    foreach ($reports as &$report) {
        if (isset($report['data_inizio_turno'])) {
            // Format the date if it's in 'YYYY-MM-DD' format
            $report['data_inizio_turno'] = date('Y-m-d', strtotime($report['data_inizio_turno']));
        }
    }

    // Output the data as JSON
    echo json_encode($reports);
} catch (Exception $e) {
    // Handle exceptions gracefully
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
