const bunyan = require('bunyan');
const koa = require('koa');

const LISTEN_PORT = 6005;

// Helper Timing Funcitons
function getRandomInt(min, max) {
  min = Math.ceil(min);
  max = Math.floor(max);
  return Math.floor(Math.random() * (max - min)) + min;
}

const waitRandomSeconds = (minSeconds, maxSeconds) =>
  new Promise((resolve, reject) =>
    setTimeout(() => resolve(true), getRandomInt(minSeconds * 1000, maxSeconds * 1000))
  );

// Logger
const log = bunyan.createLogger({
  name: 'node-webserver',
  stream: process.stdout
});

// Webserver
const app = new koa();

// Log requests
app.use(async (ctx, next) => {
  await next();
  const rt = ctx.response.get('X-Response-Time');
  log.info({ method: ctx.method, url: ctx.url, responseTime: rt });
});

// Time requests
app.use(async (ctx, next) => {
  const start = Date.now();
  await next();
  const ms = Date.now() - start;
  ctx.set('X-Response-Time', `${ms}`);
});

// Return URL
app.use(async ctx => {
  await waitRandomSeconds(0, 1);
  ctx.body = `${ctx.url}`;
});

// Start webserver
log.info('Starting webserver');
app.listen(LISTEN_PORT);

// Log a heartbeat
log.info('Starting heartbeat');
setInterval(() => {
  log.info('Alive');
}, 15 * 1000); // 15 seconds

const live = async () => {
  log.info(`I'm alive`);
  await waitRandomSeconds(60 * 1, 60 * 5);
  log.error(`Oh No! I'm Dying`);
  process.exit(1);
};

live();
