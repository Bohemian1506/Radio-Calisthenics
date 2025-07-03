const puppeteer = require('puppeteer');
const fs = require('fs');

async function takeScreenshot() {
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
  });
  
  const page = await browser.newPage();
  
  // デスクトップサイズ
  await page.setViewport({ width: 1200, height: 800 });
  
  try {
    // ホームページ
    await page.goto('http://localhost:3000', { waitUntil: 'networkidle2' });
    await page.screenshot({ path: 'screenshot-home.png', fullPage: true });
    console.log('✅ ホームページのスクリーンショットを保存: screenshot-home.png');
    
    // スタンプカードページ（ログインが必要な場合はスキップ）
    await page.goto('http://localhost:3000/stamp_cards', { waitUntil: 'networkidle2' });
    await page.screenshot({ path: 'screenshot-stamp-cards.png', fullPage: true });
    console.log('✅ スタンプカードページのスクリーンショットを保存: screenshot-stamp-cards.png');
    
    // 統計情報ページ
    await page.goto('http://localhost:3000/statistics', { waitUntil: 'networkidle2' });
    await page.screenshot({ path: 'screenshot-statistics.png', fullPage: true });
    console.log('✅ 統計情報ページのスクリーンショットを保存: screenshot-statistics.png');
    
  } catch (error) {
    console.log('⚠️ 一部のページでエラーが発生:', error.message);
  }
  
  await browser.close();
}

takeScreenshot().catch(console.error);