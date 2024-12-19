<?php

require 'connection.php'; // Assurez-vous d'avoir un fichier de connexion sécurisé

if (isset($_COOKIE['user_auth'])) {
    $cookie_value = $_COOKIE['user_auth'];

    try {
        // Récupérer les utilisateurs avec des jetons de session valides de la base de données
        $stmt = $pdo->prepare('SELECT user_id, session_token, role FROM users WHERE session_token IS NOT NULL');
        $stmt->execute();
        $users = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $isAuthenticated = false;
        $user_id = null;

        foreach ($users as $user) {
            // Fix: Added role check in a separate line
            if (password_verify($cookie_value, $user['session_token'])) {
                if ($user['role'] === 'admin') {
                    $isAuthenticated = true;
                    $user_id = $user['user_id'];
                }
                break; // Exit the loop once a match is found
            }
        }



        // Prix unitaire pour chaque type
        $unitPrices = [
            'swap_ebike' => 1.80,
            'swap_lite' => 2,
            'relocation' => 2.3,
            'repacking' => 1.5,
            'short_fix' => 2.6,
            'fix' => 2.6,
            'swap_relocation' => 3,
            'fix_swap' => 2.8,
            'fix_relocation' => 3,
            'fix_swap_relocation' => 3.2,
            'pick_up' => 2.9,
            'missing' => 3,
            'deployment' => 1.7,
            'ore_ricarica_armadio' => 16,
            'ore_fuori_area' => 21,
            'ore_app_lenta' => 22,
            'ore_segnalazioni_ritiri' => 21,
        ];

        header('Content-Type: application/json'); // Définir le type de contenu en JSON

        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            http_response_code(405);
            echo json_encode(['status' => 'error', 'message' => 'Méthode de requête non autorisée.']);
            exit;
        }

        if (!isset($_POST['fields'], $_POST['start_date'], $_POST['final_date'], $_POST['username'])) {
            http_response_code(400);
            echo json_encode(['status' => 'error', 'message' => 'Les paramètres nécessaires sont manquants.']);
            exit;
        }

        $fields = explode('+', trim($_POST['fields']));
        $startDate = trim($_POST['start_date']);
        $finalDate = trim($_POST['final_date']);
        $username = trim($_POST['username']);

        // Validation des champs
        if (empty($username) || empty($fields) || empty($startDate) || empty($finalDate)) {
            http_response_code(400);
            echo json_encode(['status' => 'error', 'message' => 'Le champ username, fields, start_date ou final_date est requis.']);
            exit;
        }

        // Liste des colonnes autorisées
        $allowedColumns = array_keys($unitPrices);
        $validFields = array_intersect($fields, $allowedColumns);

        if (empty($validFields)) {
            http_response_code(400);
            echo json_encode(['status' => 'error', 'message' => 'Aucune colonne valide sélectionnée.']);
            exit;
        }

        $columnsString = implode(', ', $validFields);

        $sql = "
            SELECT u.username, $columnsString, r.data_inizio_turno, r.inizio_turno, r.targa_furgone
            FROM reports r
            JOIN users u ON r.user_id = u.user_id
            WHERE r.data_inizio_turno BETWEEN :start_date AND :final_date";

        if (strcasecmp($username, 'ALL') !== 0) {
            $sql .= " AND u.username = :username";
        }

        try {
            $stmt = $pdo->prepare($sql);
            $params = [
                'start_date' => $startDate,
                'final_date' => $finalDate
            ];
            if (strcasecmp($username, 'ALL') !== 0) {
                $params['username'] = $username;
            }
            $stmt->execute($params);

            $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

            $totalPrices = [];
            $totalGlobalPrice = 0;

            foreach ($results as $row) {
                $userTotalPrice = 0;
                $priceDetails = [];

                foreach ($validFields as $field) {
                    if (isset($row[$field])) {
                        $quantity = (int) $row[$field]; // Cast to integer for safety
                        $price = $unitPrices[$field] * $quantity;

                        $priceDetails[$field] = [
                            'quantity' => $quantity,
                        ];
                        $userTotalPrice += $price;
                    }
                }

                $totalPrices[] = [
                    'username' => htmlspecialchars($row['username'], ENT_QUOTES, 'UTF-8'), // Escape output
                    'data_inizio_turno' => htmlspecialchars($row['data_inizio_turno'], ENT_QUOTES, 'UTF-8'),
                    'inizio_turno' => htmlspecialchars($row['inizio_turno'], ENT_QUOTES, 'UTF-8'),
                    'targa_furgone' => htmlspecialchars($row['targa_furgone'], ENT_QUOTES, 'UTF-8'),
                    'fields' => $priceDetails,
                    'user_total_price_per_day' => number_format($userTotalPrice, 2),
                ];

                $totalGlobalPrice += $userTotalPrice;
            }

            echo json_encode([
                'status' => 'success',
                'total_price' => number_format($totalGlobalPrice, 2),
                'details' => $totalPrices,
            ]);

        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(['status' => 'error', 'message' => 'Erreur interne du serveur.']);
            exit;
        }

    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Erreur de connexion à la base de données.']);
        exit;
    }
} else {
    http_response_code(401);
    echo json_encode(['error' => 'Unauthorized access.']);
    exit;
}
