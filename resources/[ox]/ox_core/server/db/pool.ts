import { createPool } from 'mariadb';
import { GetConfig } from './config';
import type { Pool } from 'mariadb';
import schema from './schema';

export let pool: Pool;

setImmediate(async () => {
  const config = GetConfig();

  try {
    const dbPool = createPool(config);
    const conn = await dbPool.getConnection();
    const info = conn.info!; // when would info be null? i'm sure we'll find out eventually!
    const version = info.serverVersion;
    const recommendedDb =
      'Install MariaDB 11.4+ for the best experience.\n- https://mariadb.com/kb/en/changes-improvements-in-mariadb-11-4/';

    conn.release();

    if (!version.mariaDb) return console.error(`MySQL ${version?.raw} is not supported. ${recommendedDb}`);

    if (!info.hasMinVersion(11, 4, 0)) return console.error(`${version.raw} is not supported. ${recommendedDb}`);

    console.log(`${`^5[${version.raw}]`} ^2Database server connection established!^0`);

    await schema(dbPool);

    pool = dbPool;
  } catch (err) {
    console.log(
      `^3Unable to establish a connection to the database (${err.code})!\n^1Error ${err.errno}: ${err.message}^0`,
    );

    if (config.password) config.password = '******';

    console.log(config);
  }
});
