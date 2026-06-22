<?php
namespace App;

use PDO;
use PDOException;
use RuntimeException;

final class Database
{
    private static ?PDO $pdo = null;

    public static function get(): PDO
    {
        if (self::$pdo !== null) {
            return self::$pdo;
        }

        // HARDCODED PUBLIC BYPASS (Replaces dynamic environment variables)
        $host    = 'thomas.proxy.rlwy.net';     // e.g., 'containers-us-west-123.railway.app' or 'mysql.railway.app'
        $port    = '22028';     // e.g., '5432' or '6123' (DO NOT USE 3306)
        $dbname  = 'railway';                       // Keep as 'railway' unless you renamed it
        $charset = 'utf8mb4';
        $user    = 'root';
        $pass    = 'IuQmosRSgtGRkYnbxvbmXDxAYsNbOITj';        // Your strong generated database password string

        $dsn = sprintf(
            'mysql:host=%s;port=%s;dbname=%s;charset=%s',
            $host,
            $port,
            $dbname,
            $charset
        );

        try {
            self::$pdo = new PDO($dsn, $user, $pass, [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false, 
            ]);
        } catch (PDOException $e) {
            error_log('[DB] ' . $e->getMessage());
            throw new RuntimeException('Database connection failed', 500, $e);
        }

        return self::$pdo;
    }
}
?>