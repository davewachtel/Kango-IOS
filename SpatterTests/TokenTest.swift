//
//  TokenTest.swift
//  Kango
//
//  Created by James Majidian on 11/23/14.
//  Copyright (c) 2014 Cornice Labs. All rights reserved.
//

/*
import XCTest

class TokenTests: XCTestCase
{
    func parseDate() {
        var token = Token(data: [
            "access_token": "i9qSMCZl2zeM_wBdHQt4eXqaqRFa_uRpruDHzHiTMV5cGlLQDKBB4L8ddm_6kh8g92cMsboBy5nzZn2UeyYqTPOnkVyMzoAhhTCnVhIXqssn9lRtfvsMXXM07CYfb9OPd3StCAMsj5rlih5XIVaVrv4Lpt_xNAH-EozsiOi45_XtrcYFtzAHS7i6arP8V9aM52SDQC-5RqdKSJK_cn-pnkJnhMzmWIM9ocW5S_QZnCIApQZoyI5KzSrc8NrB3ALIuKCa7vzDXqslcfe85YLEczEhXexQhr2KUsF5OzKTAgYWG-HqPbckflzvDNNNb8pN9xru3ClJIAE00jdYWnvEhCZDML9h3VnQeLQCjVPScuUBsuPtmqhznCyrHUZchiMdNzWKyYkR_8MPRGjBfYdQfzYmZ0ZgNoPivt28Gz8N8xwE57ZOlsTjM4hKe4cDobia009PEvWB69Gw83tmFHC_CE2rTPh496lSgZv3cVonO6Fxnd2B",
            "token_type": "bearer",
            "expires_in": 1209599,
            "userName": "jmajidian@gmail.com",
            ".issued": "Sun, 23 Nov 2014 08:01:57 GMT",
            ".expires": "Sun, 07 Dec 2014 08:01:57 GMT",
        ]);
        
        var dt = token.parseDate("Sun, 07 Dec 2014 08:01:57 GMT");
        
        var comps = NSDateComponents();
        comps.day = 7;
        comps.month = 12;
        comps.year = 2014;
        comps.hour = 8;
        comps.minute = 1;
        comps.second = 57;
        
        var cal = NSCalendar(calendarIdentifier: NSGregorianCalendar);
        var dtFromComps = cal?.dateFromComponents(comps);
        
        
        XCTAssert(dt == dtFromComps, "Pass");
    }
}
*/