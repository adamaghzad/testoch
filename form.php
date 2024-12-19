<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include 'connection.php';

// Check if 'user_auth' cookie exists
if (isset($_COOKIE['user_auth'])) {
    $cookie_value = $_COOKIE['user_auth'];

    try {
        // Retrieve users with valid session tokens from the database
        $stmt = $pdo->prepare('SELECT user_id, session_token FROM users WHERE session_token IS NOT NULL');
        $stmt->execute();
        $users = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $isAuthenticated = false;
        $user_id = null;

        foreach ($users as $user) {
            if (password_verify($cookie_value, $user['session_token'])) {
                $isAuthenticated = true;
                $user_id = $user['user_id'];
                break;
            }
        }

        if (!$isAuthenticated) {
            http_response_code(401);
            echo json_encode(['error' => 'Unauthorized access.']);
            exit;
        }

        // Process POST request if user is authenticated
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            // List of required fields
            $required_fields = ['data_inizio_turno', 'inizio_turno'];
            $optional_fields = [
                'targa_furgone', 'swap_ebike', 'swap_lite', 'relocation', 'repacking', 'short_fix', 'fix',
                'swap_relocation', 'fix_swap', 'fix_relocation', 'fix_swap_relocation', 'pick_up', 'missing',
                'deployment', 'ore_ricarica_armadio', 'ore_fuori_area', 'ore_app_lenta', 'ore_segnalazioni_ritiri',
                'km_furgone_a_fine_turno', 'note'
            ];

            // Validate required fields
            foreach ($required_fields as $field) {
                if (empty($_POST[$field])) {
                    http_response_code(400);
                    echo json_encode(['error' => "The field '$field' is required."]);
                    exit;
                }
            }

            // Escape input to avoid XSS
            $data_inizio_turno = htmlspecialchars($_POST['data_inizio_turno']);
            $inizio_turno = htmlspecialchars($_POST['inizio_turno']);

            // Handle optional fields
            // Handle optional fields
$fields = [];
foreach ($optional_fields as $field) {
    if ($field === 'note' || $field === 'km_furgone_a_fine_turno') {
        // Store NULL if the field is empty or the string "null"
        $fields[$field] = (isset($_POST[$field]) && ($_POST[$field] !== '' && $_POST[$field] !== 'null'))
                          ? htmlspecialchars($_POST[$field])
                          : null;
    } else {
        // For other fields, assign 0 if 'null' or empty
        $value = isset($_POST[$field]) ? $_POST[$field] : null;
        $fields[$field] = ($value === 'null' || empty($value)) ? 0 : htmlspecialchars($value);
    }
}


            try {
                // Prepare and execute the insertion into the database
                $stmt = $pdo->prepare('
                    INSERT INTO reports (
                        data_inizio_turno, inizio_turno, targa_furgone, swap_ebike, swap_lite, relocation, repacking, short_fix, fix,
                        swap_relocation, fix_swap, fix_relocation, fix_swap_relocation, pick_up, missing, deployment, ore_ricarica_armadio, ore_fuori_area,
                        ore_app_lenta, ore_segnalazioni_ritiri, km_furgone_a_fine_turno, note, created_at, user_id
                    ) VALUES (
                        :data_inizio_turno, :inizio_turno, :targa_furgone, :swap_ebike, :swap_lite, :relocation, :repacking, :short_fix,
                        :fix, :swap_relocation, :fix_swap, :fix_relocation, :fix_swap_relocation, :pick_up, :missing, :deployment, :ore_ricarica_armadio,
                        :ore_fuori_area, :ore_app_lenta, :ore_segnalazioni_ritiri, :km_furgone_a_fine_turno, :note, NOW(), :user_id
                    )
                ');

                $stmt->execute([
                    ':data_inizio_turno' => $data_inizio_turno,
                    ':inizio_turno' => $inizio_turno,
                    ':targa_furgone' => $fields['targa_furgone'],
                    ':swap_ebike' => $fields['swap_ebike'],
                    ':swap_lite' => $fields['swap_lite'],
                    ':relocation' => $fields['relocation'],
                    ':repacking' => $fields['repacking'],
                    ':short_fix' => $fields['short_fix'],
                    ':fix' => $fields['fix'],
                    ':swap_relocation' => $fields['swap_relocation'],
                    ':fix_swap' => $fields['fix_swap'],
                    ':fix_relocation' => $fields['fix_relocation'], // Stores 0 if null
                    ':fix_swap_relocation' => $fields['fix_swap_relocation'],
                    ':pick_up' => $fields['pick_up'],
                    ':missing' => $fields['missing'],
                    ':deployment' => $fields['deployment'],
                    ':ore_ricarica_armadio' => $fields['ore_ricarica_armadio'],
                    ':ore_fuori_area' => $fields['ore_fuori_area'],
                    ':ore_app_lenta' => $fields['ore_app_lenta'],
                    ':ore_segnalazioni_ritiri' => $fields['ore_segnalazioni_ritiri'],
                    ':km_furgone_a_fine_turno' => $fields['km_furgone_a_fine_turno'],
                    ':note' => $fields['note'],
                    ':user_id' => $user_id
                ]);

                echo json_encode(['status' => '200']);
            } catch (PDOException $e) {
                http_response_code(500);
                echo 'SQL error: ' . $e->getMessage(); // Debugging SQL error
                error_log('SQL error: ' . $e->getMessage());
            }
        } else {
            http_response_code(405);
            echo json_encode(['error' => 'Method not allowed.']);
        }

    } catch (PDOException $e) {
        http_response_code(500);
        echo 'Cookie verification error: ' . $e->getMessage(); // Debugging cookie issue
        error_log('Cookie verification error: ' . $e->getMessage());
    }

} else {
    http_response_code(401);
    echo json_encode(['error' => 'Missing authentication cookie.']);
}
?>
