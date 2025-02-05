<?php
// Asigură-te că output-ul este JSON
header('Content-Type: application/json');

// Dezactivează orice output buffer
while (ob_get_level()) {
    ob_end_clean();
}

session_start();

if (!isset($_SESSION['currentUser'])) {
    echo json_encode(['error' => 'Nu sunteți autentificat']);
    exit();
}

$username = $_SESSION['currentUser']['username'];

try {
    $conn = new PDO("mysql:host=localhost;dbname=test", "root", "student");
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Obține ID-ul utilizatorului
    $stmt = $conn->prepare("SELECT tip, id FROM useri WHERE username = ?");
    $stmt->execute([$username]);
    $user = $stmt->fetch();
    
    if ($user) {
        // Obține configurările temei
        $stmt = $conn->prepare("SELECT accent, clr, sidebar, text, card, hover FROM teme WHERE id_usr = ?");
        $stmt->execute([$user['id']]);
        $theme = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($theme) {
            echo json_encode([
                'success' => true,
				'theme' => [
				                   'accent' => $theme['accent'],
				                   'clr' => $theme['clr'],
				                   'sidebar' => $theme['sidebar'],
				                   'text' => $theme['text'],
				                   'card' => $theme['card'],
				                   'hover' => $theme['hover']
				               ]
            ]);
        } else {
            echo json_encode([
                'success' => true,
                'theme' => [
                    'accent' => '#0079c1',
                    'clr' => '#ffffff',
                    'sidebar' => '#ffffff',
                    'text' => '#000000',
                    'card' => '#ffffff',
                    'hover' => '#005a91'
                ]
            ]);
        }
    } else {
        echo json_encode(['error' => 'Utilizator negăsit']);
    }
} catch(PDOException $e) {
    echo json_encode(['error' => $e->getMessage()]);
}
?>