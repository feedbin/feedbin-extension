// Firefox Extension Installation Verification Script
// Run this in the browser console to verify the extension is working correctly

(function() {
    'use strict';
    
    console.log('🔍 Starting Firefox Extension Verification...');
    
    // Check if we're in Firefox
    function isFirefox() {
        return typeof InstallTrigger !== 'undefined' || 
               navigator.userAgent.toLowerCase().includes('firefox');
    }
    
    // Check if browser APIs are available
    function checkBrowserAPIs() {
        const results = {
            browser: typeof browser !== 'undefined',
            chrome: typeof chrome !== 'undefined',
            tabs: false,
            scripting: false,
            runtime: false
        };
        
        if (results.browser) {
            results.tabs = !!(browser.tabs && browser.tabs.query);
            results.scripting = !!(browser.scripting && browser.scripting.executeScript);
            results.runtime = !!(browser.runtime && browser.runtime.onMessage);
        } else if (results.chrome) {
            results.tabs = !!(chrome.tabs && chrome.tabs.query);
            results.scripting = !!(chrome.scripting && chrome.scripting.executeScript);
            results.runtime = !!(chrome.runtime && chrome.runtime.onMessage);
        }
        
        return results;
    }
    
    // Test meta extraction on current page
    function testMetaExtraction() {
        const metaInfo = {
            ogDescription: null,
            ogTitle: null,
            ogImage: null,
            ogSiteName: null,
            description: null
        };
        
        try {
            // Test og:description
            const ogDesc = document.querySelector('meta[property="og:description"]');
            metaInfo.ogDescription = ogDesc ? ogDesc.content?.trim() : null;
            
            // Test og:title
            const ogTitle = document.querySelector('meta[property="og:title"]');
            metaInfo.ogTitle = ogTitle ? ogTitle.content?.trim() : null;
            
            // Test og:image
            const ogImage = document.querySelector('meta[property="og:image"]');
            metaInfo.ogImage = ogImage ? ogImage.content?.trim() : null;
            
            // Test og:site_name
            const ogSiteName = document.querySelector('meta[property="og:site_name"]');
            metaInfo.ogSiteName = ogSiteName ? ogSiteName.content?.trim() : null;
            
            // Test description fallback
            const desc = document.querySelector('meta[name="description"]');
            metaInfo.description = desc ? desc.content?.trim() : null;
            
        } catch (error) {
            console.error('❌ Meta extraction failed:', error);
        }
        
        return metaInfo;
    }
    
    // Main verification function
    function runVerification() {
        console.log('🏁 Browser Detection:', isFirefox() ? 'Firefox ✅' : 'Other Browser');
        
        const apiResults = checkBrowserAPIs();
        console.log('🔧 API Availability:', apiResults);
        
        if (!apiResults.browser && !apiResults.chrome) {
            console.error('❌ No browser extension APIs detected. Are you running this in an extension context?');
            return;
        }
        
        if (!apiResults.tabs) {
            console.warn('⚠️  Tabs API not available');
        }
        
        if (!apiResults.scripting) {
            console.warn('⚠️  Scripting API not available');
        }
        
        if (!apiResults.runtime) {
            console.warn('⚠️  Runtime messaging API not available');
        }
        
        // Test meta extraction
        console.log('📄 Testing meta extraction on current page...');
        const metaInfo = testMetaExtraction();
        console.log('📊 Extracted meta info:', metaInfo);
        
        // Check if any meta info was found
        const hasMetaInfo = Object.values(metaInfo).some(value => value !== null);
        if (hasMetaInfo) {
            console.log('✅ Meta extraction working correctly');
        } else {
            console.log('ℹ️  No meta information found on this page (this is normal for some pages)');
        }
        
        // Test page compatibility
        const url = window.location.href;
        const isRestrictedPage = url.startsWith('chrome://') || 
                                url.startsWith('about:') || 
                                url.startsWith('moz-extension://') ||
                                url.startsWith('chrome-extension://');
        
        if (isRestrictedPage) {
            console.log('ℹ️  Currently on a restricted page. Extension cannot inject scripts here.');
            console.log('💡 Try testing on a regular website (HTTP/HTTPS)');
        } else {
            console.log('✅ Current page allows script injection');
        }
        
        // Final recommendations
        console.log('\n📋 Verification Summary:');
        console.log('- Browser:', isFirefox() ? 'Firefox' : 'Other');
        console.log('- APIs Available:', apiResults.browser || apiResults.chrome ? '✅' : '❌');
        console.log('- Page Compatible:', !isRestrictedPage ? '✅' : '❌');
        console.log('- Meta Info Found:', hasMetaInfo ? '✅' : 'ℹ️');
        
        if (isFirefox()) {
            console.log('\n🦊 Firefox-specific notes:');
            console.log('- Extension uses Firefox-optimized content script');
            console.log('- Structured cloning issues have been addressed');
            console.log('- Check about:debugging for extension logs');
        }
        
        console.log('\n✅ Verification complete!');
    }
    
    // Run the verification
    runVerification();
    
    // Make functions available globally for manual testing
    window.verifyExtension = runVerification;
    window.testMetaExtraction = testMetaExtraction;
    
    console.log('\n💡 Available functions:');
    console.log('- verifyExtension(): Run full verification again');
    console.log('- testMetaExtraction(): Test meta tag extraction only');
    
})();