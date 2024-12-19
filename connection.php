<?php
// Désactiver l'affichage des erreurs aux utilisateurs
ini_set('display_errors', 0);
ini_set('display_startup_errors', 0);
error_reporting(0);

// Activer le logging des erreurs
ini_set('log_errors', 1);
ini_set('error_log', '/home/shark/Desktop/error.log'); // Spécifiez le chemin vers le fichier de log des erreurs
if (basename($_SERVER['PHP_SELF']) == basename(__FILE__)) {
    http_response_code(403);
    exit('Accès interdit');
}
// Détails de la connexion à la base de données
$host = 'localhost';
$dbname = 'testoch';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Échec de la connexion à la base de données.']);
    error_log('Erreur de connexion à la base de données : ' . $e->getMessage());
    exit;
}

