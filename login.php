<?php

 include 'connection.php';

// Vérifier si la méthode de la requête est POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    // Limitation des tentatives de connexion (prévention contre force brute)
    session_start();
    if (!isset($_SESSION['login_attempts'])) {
        $_SESSION['login_attempts'] = 0;
    }

    if ($_SESSION['login_attempts'] > 10) {
        http_response_code(429); // Trop de tentatives
        echo json_encode(['status' => 'error', 'message' => 'Trop de tentatives de connexion. Veuillez réessayer plus tard.']);
        exit;
    }

    // Validation des champs
    if (!isset($_POST['username']) || !isset($_POST['password'])) {
        http_response_code(400); // Mauvaise requête
        echo json_encode(['status' => 'error', 'message' => 'Nom d\'utilisateur ou mot de passe manquant']);
        exit;
    }

    $inputUsername = trim($_POST['username']);
    $inputPassword = trim($_POST['password']);

    // Validation de l'entrée utilisateur pour éviter les caractères non autorisés
    if (!preg_match('/^[a-zA-Z0-9_]+$/', $inputUsername)) {
        http_response_code(400); // Mauvaise requête
        echo json_encode(['status' => 'error', 'message' => 'Format du nom d\'utilisateur invalide']);
        exit;
    }

    try {
        // Requête préparée pour éviter les injections SQL
        $stmt = $pdo->prepare('SELECT * FROM users WHERE username = :username');
        $stmt->execute(['username' => $inputUsername]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        // Vérifier le mot de passe
        if ($user && password_verify($inputPassword, $user['password'])) {
            // Générer un token de session sécurisé
            $cookieValue = bin2hex(random_bytes(16));
            $encryptedCookie = password_hash($cookieValue, PASSWORD_BCRYPT);

            // Mettre à jour le token de session dans la base de données
            $updateStmt = $pdo->prepare('UPDATE users SET session_token = :session_token WHERE user_id = :user_id');
            $updateStmt->execute([
                'session_token' => $encryptedCookie,
                'user_id' => $user['user_id']
            ]);

            // Réinitialiser les tentatives de connexion après un succès
            $_SESSION['login_attempts'] = 0;

            // Réponse JSON sécurisée
            echo json_encode([
                'status' => 'success',
                'cookie' => $cookieValue,
                'is_admin' => $user['role'] === 'admin' ? 1 : 0
            ]);
        } else {
            // Augmenter le compteur de tentatives après une erreur de connexion
            $_SESSION['login_attempts']++;

            http_response_code(401); // Non autorisé
            echo json_encode(['status' => 'error', 'message' => 'Nom d\'utilisateur ou mot de passe invalide']);
        }
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Une erreur interne est survenue.']);
        error_log('Erreur SQL : ' . $e->getMessage());
    }
} else {
    http_response_code(405); // Méthode non autorisée
    header('Allow: POST');
    echo json_encode(['status' => 'error', 'message' => 'Méthode non autorisée.']);
}
?>
