<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress' );

/** MySQL database username */
define( 'DB_USER', 'myung' );

/** MySQL database password */
define( 'DB_PASSWORD', '42Mysql' );

/** MySQL hostname */
define( 'DB_HOST', 'localhost' );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/** FILESYSTEM method set to direct */
define( 'FS_METHOD', 'direct' );

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         'f.m`|i7h6,bmI#8Pf ~r%d&}&/eQMLpH^NYq$h_#v7q:EpK:F![%??!qCvrDfHH:');
define('SECURE_AUTH_KEY',  '~E]A r+~&/6k-x%>a:L;)4rM>I|__HKDI/-?w9$sohAb.C/]B-a?-U5LyKDXL.dD');
define('LOGGED_IN_KEY',    'd7[T3ZmH-u~|x$sfW0hp<DSo))!|Etl5f:M@J L!Anjha4`&D(#k:&6pz~z.uef<');
define('NONCE_KEY',        'KnxQfa$6<t&y8$h;B`JvJ_&:Atgvlc!m1G?i#5/Ik@Xu_.!zkXbT%ASv:6$^V@ts');
define('AUTH_SALT',        '^b0Vd`p8|Jxcb >X!5kMrX_vut!&WPGi$1f=GgU.c^LV.-`lx,8.%^A)!if[pXlt');
define('SECURE_AUTH_SALT', '[B0lP%DLWIc0GIUWa0N(%k]/Zmlo)fz--MfOr-27h`|vthDb$J#.Ky|#>>]RZ9;Q');
define('LOGGED_IN_SALT',   'Q=; Th/&6d=1?8;v]u[.SM_cXA0SjRiQTMvM^(!!c|lP.!OGC6Er6=o{#o7LE3lM');
define('NONCE_SALT',       'sbxxF&>oh^H6:B?BKUgu-[qUv@XgWG,qs|}AK5|}xvLNZJ32.2 -8~(CzS=;/{BQ');

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the Codex.
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */
define( 'WP_DEBUG', false );

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', dirname( __FILE__ ) . '/' );
}

#redirect HTTP to HTTPS
if ($_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') $_SERVER['HTTPS']='on';

/** Sets up WordPress vars and included files. */
require_once( ABSPATH . 'wp-settings.php' );
