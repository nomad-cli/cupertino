(function () {
    var a = false,
        b = /xyz/.test(function () {}) ? /\b_super\b/ : /.*/;
    this.Class = function () {};
    Class.extend = function (g) {
        var f = this.prototype,
            e, d;
        a = true;
        d = new this();
        a = false;
        for (e in g) {
            d[e] = typeof g[e] == "function" && typeof f[e] == "function" && b.test(g[e]) ? (function (h, i) {
                return function () {
                    var k = this._super,
                        j;
                    this._super = f[h];
                    j = i.apply(this, arguments);
                    this._super = k;
                    return j
                }
            })(e, g[e]) : g[e]
        }

        function c() {
            if (!a && this.init) {
                this.init.apply(this, arguments)
            }
        }
        c.prototype = d;
        c.constructor = c;
        c.extend = arguments.callee;
        return c
    }
})();
(function (j, o, r) {
    var q = "hashchange",
        l = document,
        n, m = j.event.special,
        k = l.documentMode,
        p = "on" + q in o && (k === r || k > 7);

    function s(a) {
        a = a || location.href;
        return "#" + a.replace(/^[^#]*#?(.*)$/, "$1")
    }
    j.fn[q] = function (a) {
        return a ? this.bind(q, a) : this.trigger(q)
    };
    j.fn[q].delay = 50;
    m[q] = j.extend(m[q], {
        setup: function () {
            if (p) {
                return false
            }
            j(n.start)
        },
        teardown: function () {
            if (p) {
                return false
            }
            j(n.stop)
        }
    });
    n = (function () {
        var d = {}, e, a = s(),
            c = function (h) {
                return h
            }, b = c,
            f = c;
        d.start = function () {
            e || g()
        };
        d.stop = function () {
            e && clearTimeout(e);
            e = r
        };

        function g() {
            var h = s(),
                i = f(a);
            if (h !== a) {
                b(a = h, i);
                j(o)
                    .trigger(q)
            } else {
                if (i !== a) {
                    location.href = location.href.replace(/#.*/, "") + i
                }
            }
            e = setTimeout(g, j.fn[q].delay)
        }
        j.browser.msie && !p && (function () {
            var i, h;
            d.start = function () {
                if (!i) {
                    h = j.fn[q].src;
                    h = h && h + s();
                    i = j('<iframe tabindex="-1" title="empty"/>')
                        .hide()
                        .one("load", function () {
                            h || b(s());
                            g()
                        })
                        .attr("src", h || "javascript:0")
                        .insertAfter("body")[0].contentWindow;
                    l.onpropertychange = function () {
                        try {
                            if (event.propertyName === "title") {
                                i.document.title = l.title
                            }
                        } catch (t) {}
                    }
                }
            };
            d.stop = c;
            f = function () {
                return s(i.location.href)
            };
            b = function (w, z) {
                var x = i.document,
                    y = j.fn[q].domain;
                if (w !== z) {
                    x.title = l.title;
                    x.open();
                    y && x.write('<script>document.domain="' + y + '"<\/script>');
                    x.close();
                    i.location.hash = w
                }
            }
        })();
        return d
    })()
})(jQuery, this);
(function () {
    var r = "0.2.2",
        i = window.jQuery || window.$ || (window.$ = {}),
        f = {
            parse: window.JSON && (window.JSON.parse || window.JSON.decode) || String.prototype.evalJSON && function (A) {
                return String(A)
                    .evalJSON()
            } || i.parseJSON || i.evalJSON,
            stringify: window.JSON && (window.JSON.stringify || window.JSON.encode) || Object.toJSON || i.toJSON
        };
    if (!f.parse || !f.stringify) {
        throw new Error("No JSON support found, include //cdnjs.cloudflare.com/ajax/libs/json2/20110223/json2.js to page")
    }
    var l = {}, c = {
            jStorage: "{}"
        }, v = null,
        n = 0,
        h = false,
        j = {}, a = false,
        d = 0,
        x, w = "00000000 77073096 EE0E612C 990951BA 076DC419 706AF48F E963A535 9E6495A3 0EDB8832 79DCB8A4 E0D5E91E 97D2D988 09B64C2B 7EB17CBD E7B82D07 90BF1D91 1DB71064 6AB020F2 F3B97148 84BE41DE 1ADAD47D 6DDDE4EB F4D4B551 83D385C7 136C9856 646BA8C0 FD62F97A 8A65C9EC 14015C4F 63066CD9 FA0F3D63 8D080DF5 3B6E20C8 4C69105E D56041E4 A2677172 3C03E4D1 4B04D447 D20D85FD A50AB56B 35B5A8FA 42B2986C DBBBC9D6 ACBCF940 32D86CE3 45DF5C75 DCD60DCF ABD13D59 26D930AC 51DE003A C8D75180 BFD06116 21B4F4B5 56B3C423 CFBA9599 B8BDA50F 2802B89E 5F058808 C60CD9B2 B10BE924 2F6F7C87 58684C11 C1611DAB B6662D3D 76DC4190 01DB7106 98D220BC EFD5102A 71B18589 06B6B51F 9FBFE4A5 E8B8D433 7807C9A2 0F00F934 9609A88E E10E9818 7F6A0DBB 086D3D2D 91646C97 E6635C01 6B6B51F4 1C6C6162 856530D8 F262004E 6C0695ED 1B01A57B 8208F4C1 F50FC457 65B0D9C6 12B7E950 8BBEB8EA FCB9887C 62DD1DDF 15DA2D49 8CD37CF3 FBD44C65 4DB26158 3AB551CE A3BC0074 D4BB30E2 4ADFA541 3DD895D7 A4D1C46D D3D6F4FB 4369E96A 346ED9FC AD678846 DA60B8D0 44042D73 33031DE5 AA0A4C5F DD0D7CC9 5005713C 270241AA BE0B1010 C90C2086 5768B525 206F85B3 B966D409 CE61E49F 5EDEF90E 29D9C998 B0D09822 C7D7A8B4 59B33D17 2EB40D81 B7BD5C3B C0BA6CAD EDB88320 9ABFB3B6 03B6E20C 74B1D29A EAD54739 9DD277AF 04DB2615 73DC1683 E3630B12 94643B84 0D6D6A3E 7A6A5AA8 E40ECF0B 9309FF9D 0A00AE27 7D079EB1 F00F9344 8708A3D2 1E01F268 6906C2FE F762575D 806567CB 196C3671 6E6B06E7 FED41B76 89D32BE0 10DA7A5A 67DD4ACC F9B9DF6F 8EBEEFF9 17B7BE43 60B08ED5 D6D6A3E8 A1D1937E 38D8C2C4 4FDFF252 D1BB67F1 A6BC5767 3FB506DD 48B2364B D80D2BDA AF0A1B4C 36034AF6 41047A60 DF60EFC3 A867DF55 316E8EEF 4669BE79 CB61B38C BC66831A 256FD2A0 5268E236 CC0C7795 BB0B4703 220216B9 5505262F C5BA3BBE B2BD0B28 2BB45A92 5CB36A04 C2D7FFA7 B5D0CF31 2CD99E8B 5BDEAE1D 9B64C2B0 EC63F226 756AA39C 026D930A 9C0906A9 EB0E363F 72076785 05005713 95BF4A82 E2B87A14 7BB12BAE 0CB61B38 92D28E9B E5D5BE0D 7CDCEFB7 0BDBDF21 86D3D2D4 F1D4E242 68DDB3F8 1FDA836E 81BE16CD F6B9265B 6FB077E1 18B74777 88085AE6 FF0F6A70 66063BCA 11010B5C 8F659EFF F862AE69 616BFFD3 166CCF45 A00AE278 D70DD2EE 4E048354 3903B3C2 A7672661 D06016F7 4969474D 3E6E77DB AED16A4A D9D65ADC 40DF0B66 37D83BF0 A9BCAE53 DEBB9EC5 47B2CF7F 30B5FFE9 BDBDF21C CABAC28A 53B39330 24B4A3A6 BAD03605 CDD70693 54DE5729 23D967BF B3667A2E C4614AB8 5D681B02 2A6F2B94 B40BBE37 C30C8EA1 5A05DF1B 2D02EF8D",
        y = {
            isXML: function (B) {
                var A = (B ? B.ownerDocument || B : 0)
                    .documentElement;
                return A ? A.nodeName !== "HTML" : false
            },
            encode: function (B) {
                if (!this.isXML(B)) {
                    return false
                }
                try {
                    return new XMLSerializer()
                        .serializeToString(B)
                } catch (A) {
                    try {
                        return B.xml
                    } catch (C) {}
                }
                return false
            },
            decode: function (B) {
                var A = ("DOMParser" in window && (new DOMParser())
                    .parseFromString) || (window.ActiveXObject && function (D) {
                    var E = new ActiveXObject("Microsoft.XMLDOM");
                    E.async = "false";
                    E.loadXML(D);
                    return E
                }),
                    C;
                if (!A) {
                    return false
                }
                C = A.call("DOMParser" in window && (new DOMParser()) || window, B, "text/xml");
                return this.isXML(C) ? C : false
            }
        };

    function p() {
        var A = false;
        if ("localStorage" in window) {
            try {
                window.localStorage.setItem("_tmptest", "tmpval");
                A = true;
                window.localStorage.removeItem("_tmptest")
            } catch (B) {}
        }
        if (A) {
            try {
                if (window.localStorage) {
                    c = window.localStorage;
                    h = "localStorage";
                    d = c.jStorage_update
                }
            } catch (G) {}
        } else {
            if ("globalStorage" in window) {
                try {
                    if (window.globalStorage) {
                        c = window.globalStorage[window.location.hostname];
                        h = "globalStorage";
                        d = c.jStorage_update
                    }
                } catch (F) {}
            } else {
                v = document.createElement("link");
                if (v.addBehavior) {
                    v.style.behavior = "url(#default#userData)";
                    document.getElementsByTagName("head")[0].appendChild(v);
                    v.load("jStorage");
                    var E = "{}";
                    try {
                        E = v.getAttribute("jStorage")
                    } catch (D) {}
                    try {
                        d = v.getAttribute("jStorage_update")
                    } catch (C) {}
                    c.jStorage = E;
                    h = "userDataBehavior"
                } else {
                    v = null;
                    return
                }
            }
        }
        k();
        b();
        t()
    }

    function e() {
        var C = "{}";
        if (h == "userDataBehavior") {
            v.load("jStorage");
            try {
                C = v.getAttribute("jStorage")
            } catch (B) {}
            try {
                d = v.getAttribute("jStorage_update")
            } catch (A) {}
            c.jStorage = C
        }
        k()
    }

    function t() {
        if (h == "localStorage" || h == "globalStorage") {
            if ("addEventListener" in window) {
                window.addEventListener("storage", o, false)
            } else {
                document.attachEvent("onstorage", o)
            }
        } else {
            if (h == "userDataBehavior") {
                setInterval(o, 1000)
            }
        }
    }

    function o() {
        var A;
        clearTimeout(a);
        a = setTimeout(function () {
            if (h == "localStorage" || h == "globalStorage") {
                A = c.jStorage_update
            } else {
                if (h == "userDataBehavior") {
                    v.load("jStorage");
                    try {
                        A = v.getAttribute("jStorage_update")
                    } catch (B) {}
                }
            } if (A && A != d) {
                d = A;
                g()
            }
        }, 100)
    }

    function g() {
        var A = f.parse(f.stringify(l.__jstorage_meta.CRC32)),
            E;
        e();
        E = f.parse(f.stringify(l.__jstorage_meta.CRC32));
        var C, B = [],
            D = [];
        for (C in A) {
            if (A.hasOwnProperty(C)) {
                if (!E[C]) {
                    D.push(C);
                    continue
                }
                if (A[C] != E[C]) {
                    B.push(C)
                }
            }
        }
        for (C in E) {
            if (E.hasOwnProperty(C)) {
                if (!A[C]) {
                    B.push(C)
                }
            }
        }
        z(B, "updated");
        z(D, "deleted")
    }

    function z(F, G) {
        F = [].concat(F || []);
        if (G == "flushed") {
            F = [];
            for (var E in j) {
                if (j.hasOwnProperty(E)) {
                    F.push(E)
                }
            }
            G = "deleted"
        }
        for (var D = 0, A = F.length; D < A; D++) {
            if (j[F[D]]) {
                for (var C = 0, B = j[F[D]].length; C < B; C++) {
                    j[F[D]][C](F[D], G)
                }
            }
        }
    }

    function m() {
        var A = (+new Date())
            .toString();
        if (h == "localStorage" || h == "globalStorage") {
            c.jStorage_update = A
        } else {
            if (h == "userDataBehavior") {
                v.setAttribute("jStorage_update", A);
                v.save("jStorage")
            }
        }
        o()
    }

    function k() {
        if (c.jStorage) {
            try {
                l = f.parse(String(c.jStorage))
            } catch (A) {
                c.jStorage = "{}"
            }
        } else {
            c.jStorage = "{}"
        }
        n = c.jStorage ? String(c.jStorage)
            .length : 0;
        if (!l.__jstorage_meta) {
            l.__jstorage_meta = {}
        }
        if (!l.__jstorage_meta.CRC32) {
            l.__jstorage_meta.CRC32 = {}
        }
    }

    function q() {
        try {
            c.jStorage = f.stringify(l);
            if (v) {
                v.setAttribute("jStorage", c.jStorage);
                v.save("jStorage")
            }
            n = c.jStorage ? String(c.jStorage)
                .length : 0
        } catch (A) {}
    }

    function s(A) {
        if (!A || (typeof A != "string" && typeof A != "number")) {
            throw new TypeError("Key name must be string or numeric")
        }
        if (A == "__jstorage_meta") {
            throw new TypeError("Reserved key name")
        }
        return true
    }

    function b() {
        var G, B, E, C, D = Infinity,
            F = false,
            A = [];
        clearTimeout(x);
        if (!l.__jstorage_meta || typeof l.__jstorage_meta.TTL != "object") {
            return
        }
        G = +new Date();
        E = l.__jstorage_meta.TTL;
        C = l.__jstorage_meta.CRC32;
        for (B in E) {
            if (E.hasOwnProperty(B)) {
                if (E[B] <= G) {
                    delete E[B];
                    delete C[B];
                    delete l[B];
                    F = true;
                    A.push(B)
                } else {
                    if (E[B] < D) {
                        D = E[B]
                    }
                }
            }
        }
        if (D != Infinity) {
            x = setTimeout(b, D - G)
        }
        if (F) {
            q();
            m();
            z(A, "deleted")
        }
    }

    function u(E, D) {
        D = D || 0;
        var F = 0,
            B = 0;
        D = D ^ (-1);
        for (var C = 0, A = E.length; C < A; C++) {
            F = (D ^ E.charCodeAt(C)) & 255;
            B = "0x" + w.substr(F * 9, 8);
            D = (D >>> 8) ^ B
        }
        return D ^ (-1)
    }
    i.jStorage = {
        version: r,
        set: function (B, C, A) {
            s(B);
            A = A || {};
            if (typeof C == "undefined") {
                this.deleteKey(B);
                return C
            }
            if (y.isXML(C)) {
                C = {
                    _is_xml: true,
                    xml: y.encode(C)
                }
            } else {
                if (typeof C == "function") {
                    return undefined
                } else {
                    if (C && typeof C == "object") {
                        C = f.parse(f.stringify(C))
                    }
                }
            }
            l[B] = C;
            l.__jstorage_meta.CRC32[B] = u(f.stringify(C));
            this.setTTL(B, A.TTL || 0);
            m();
            z(B, "updated");
            return C
        },
        get: function (A, B) {
            s(A);
            if (A in l) {
                if (l[A] && typeof l[A] == "object" && l[A]._is_xml && l[A]._is_xml) {
                    return y.decode(l[A].xml)
                } else {
                    return l[A]
                }
            }
            return typeof (B) == "undefined" ? null : B
        },
        deleteKey: function (A) {
            s(A);
            if (A in l) {
                delete l[A];
                if (typeof l.__jstorage_meta.TTL == "object" && A in l.__jstorage_meta.TTL) {
                    delete l.__jstorage_meta.TTL[A]
                }
                delete l.__jstorage_meta.CRC32[A];
                q();
                m();
                z(A, "deleted");
                return true
            }
            return false
        },
        setTTL: function (B, A) {
            var C = +new Date();
            s(B);
            A = Number(A) || 0;
            if (B in l) {
                if (!l.__jstorage_meta.TTL) {
                    l.__jstorage_meta.TTL = {}
                }
                if (A > 0) {
                    l.__jstorage_meta.TTL[B] = C + A
                } else {
                    delete l.__jstorage_meta.TTL[B]
                }
                q();
                b();
                return true
            }
            return false
        },
        getTTL: function (B) {
            var C = +new Date(),
                A;
            s(B);
            if (B in l && l.__jstorage_meta.TTL && l.__jstorage_meta.TTL[B]) {
                A = l.__jstorage_meta.TTL[B] - C;
                return A || 0
            }
            return 0
        },
        flush: function () {
            l = {
                __jstorage_meta: {
                    CRC32: {}
                }
            };
            q();
            m();
            z(null, "flushed");
            return true
        },
        storageObj: function () {
            function A() {}
            A.prototype = l;
            return new A()
        },
        index: function () {
            var A = [],
                B;
            for (B in l) {
                if (l.hasOwnProperty(B) && B != "__jstorage_meta") {
                    A.push(B)
                }
            }
            return A
        },
        storageSize: function () {
            return n
        },
        currentBackend: function () {
            return h
        },
        storageAvailable: function () {
            return !!h
        },
        listenKeyChange: function (A, B) {
            s(A);
            if (!j[A]) {
                j[A] = []
            }
            j[A].push(B)
        },
        stopListening: function (B, C) {
            s(B);
            if (!j[B]) {
                return
            }
            if (!C) {
                delete j[B];
                return
            }
            for (var A = j[B].length - 1; A >= 0; A--) {
                if (j[B][A] == C) {
                    j[B].splice(A, 1)
                }
            }
        },
        reInit: function () {
            var A, C;
            if (h == "userDataBehavior") {
                A = document.createElement("link");
                v.parentNode.replaceChild(A, v);
                v = A;
                v.style.behavior = "url(#default#userData)";
                document.getElementsByTagName("head")[0].appendChild(v);
                v.load("jStorage");
                C = "{}";
                try {
                    C = v.getAttribute("jStorage")
                } catch (B) {}
                c.jStorage = C;
                h = "userDataBehavior"
            }
            k()
        }
    };
    p()
})();
window.navigationStorageObject = Class.extend({
    trackStates: function (a) {
        if (menu.getCurrentMenuItems()
            .length > 0) {
            this.save()
        } else {
            this.read()
        } if (a) {
            this.expand()
        }
    },
    save: function () {
        var a = this.getNameByURL(location.pathname),
            b;
        if (a) {
            b = {
                expanded: true,
                filters: nav.getURLParams(),
                url: location.pathname + location.search
            };
            $.jStorage.set(a, b, nav.config.navStorageExpiration);
            menu.selectMenuItemVisuallyByURL(b.url)
        }
    },
    read: function () {
        var a = this.getNameByURL(menu.getSelectedURL()),
            b;
        if (a) {
            b = $.jStorage.get(a) || {};
            if (b.filters && b.url) {
                menu.selectMenuItemVisuallyByURL(b.url)
            }
        }
    },
    expand: function () {
        $($.jStorage.index())
            .each(function (a, b) {
                var c;
                if (b) {
                    c = $.jStorage.get(b);
                    if (c.expanded && c.url) {
                        menu.expandMenuByURL(c.url)
                    }
                }
            })
    },
    saveExpanded: function (a) {
        var b = this.getNameByURL(menu.getFirstURLInMenu(a)),
            c;
        if (b) {
            c = $.jStorage.get(b) || {};
            c.expanded = a.hasClass("selected");
            c.url = c.url || url;
            $.jStorage.set(b, c)
        }
    },
    getCurrentFilters: function () {
        var a = this.getNameByURL(location.pathname),
            b;
        if (a) {
            b = $.jStorage.get(a)
        }
        return (b ? b.filters || false : false)
    },
    getCurrentFilter: function (b) {
        var a = this.getCurrentFilters();
        return a[b] || false
    },
    readVariable: function (a) {
        return (a ? $.jStorage.get(a) || false : false)
    },
    saveVariable: function (c, d, a) {
        var b = a ? {
            TTL: a
        } : {};
        $.jStorage.set(c, d, b)
    },
    getNameByURL: function (a) {
        var b;
        if (!a) {
            return ""
        }
        b = a.split("/");
        b.shift();
        b.shift();
        b.pop();
        return b.join("_")
    }
});
window.navObject = Class.extend({
    config: {
        animationDuration: 300,
        formStorageExpiration: 18000000,
        formLoadingOpacity: 0.25,
        loadingOpacity: 0,
        navStorageExpiration: false,
        pollingInterval: 8000,
        popupWidth: 480,
        actionPrefixes: ["Complete", "Complete", "Configure", "Confirm", "Create", "CreateDistribution", "CreatePush", "CreatePass", "Download", "Edit", "Generate", "ImportUpload", "Landing", "PendingApproval", "Processing", "Remove", "Request", "Reset", "Revoke", "RevokeConfirmation"]
    },
    animateTransitions: history.pushState,
    contentReference: ".innercontent",
    currentURL: false,
    isAnimating: false,
    isInitialized: false,
    isInitialLoad: true,
    pageAnimationDuration: 500,
    sidebarAnimationDuration: 0,
    sidebarPadding1: 28,
    sidebarPadding2: 33,
    usePushState: history.pushState,
    useRetina: true,
    initialize: function () {
        if (!this.isInitialized) {
            this.initializeAjax();
            menu.initializeNav();
            this.initializePage();
            menu.selectMenuItemByPage(false, false, true, true)
        }
    },
    initializeAjax: function () {
        this.isSlowBrowser = navigator.userAgent.indexOf("MSIE") > -1 || navigator.userAgent.indexOf("Mobile") > -1;
        this.showLoadingState();
        this.isInitialized = true;
        if (this.usePushState) {
            $(window)
                .bind("popstate", $.proxy(this.pagechange, this));
            if (navigator.userAgent.indexOf("Firefox") > -1) {
                this.pagechange()
            }
        } else {
            $(window)
                .hashchange($.proxy(this.hashchange, this));
            this.hashchange()
        }
    },
    initializePage: function () {
        $(".navLink")
            .click($.proxy(this.onCustomLinkClicked, this));
        if (!grid) {
            this.resizeSections();
            this.hideLoadingState()
        }
    },
    showError: function (c, a, d) {
        var b;
        if (c && c.status == 0) {
            location.href = location.href;
            return false
        }
        a = a && a != "error" && typeof a != "object" ? a.replace(/\\n/g, "<br/>") : $(".errorGenericMessage")
            .html();
        b = this.popup(this.config.popupWidth, "An unspecified error occurred.", a, "OK");
        if (d) {
            b.find(".ok")
                .click(d)
        }
        this.animateContentIn()
    },
    hideError: function () {
        if (this.errorDiv) {
            this.errorDiv.dialog("close")
        }
    },
    showLoadingState: function (b) {
        var f, e, a, c = $(".loadingMessage"),
            d = $(".innercontent > div");
        if (!d || d.length == 0) {
            return this.showError()
        }
        this.hideLoadingState();
        if (this.isSlowBrowser) {
            $("<div>")
                .addClass("loadingBlocker")
                .height($(document)
                    .height())
                .appendTo("body")
        }
        f = Math.round(d.offset()
            .left + d.width() / 2 - c.width() / 2);
        a = $(window)
            .height() > $("body")
            .height() ? $("body")
            .height() : $(window)
            .height();
        e = Math.round((a - c.height()) / 2);
        if (b) {
            c.css({
                left: f
            })
                .show();
            c.animate({
                top: e
            }, this.animationDuration)
        } else {
            c.css({
                left: f,
                top: e
            })
                .show()
        }
    },
    hideLoadingState: function () {
        $(".loadingMessage")
            .hide();
        $(".loadingBlocker")
            .remove()
    },
    animateContentOut: function (a) {
        var b = $(this.contentReference);
        if (this.animateTransitions && b.css("opacity") == 1) {
            if (a) {
                $(".content")
                    .addClass("opaque");
                b.css({
                    opacity: this.config.formLoadingOpacity
                })
            } else {
                $(".content")
                    .removeClass("opaque");
                b.css({
                    opacity: this.config.loadingOpacity
                })
            }
        }
    },
    animateContentIn: function () {
        $(".content")
            .removeClass("opaque");
        if (this.animateTransitions) {
            $(this.contentReference)
                .animate({
                    opacity: 1
                }, this.pageAnimationDuration, $.proxy(function () {
                    if (!grid) {
                        this.hideLoadingState()
                    }
                    this.isAnimating = false
                }, this))
        } else {
            this.hideLoadingState()
        }
    },
    resizeSections: function (b, c) {
        var d = $(this.contentReference + " > div"),
            a = d.height() + parseInt(d.css("padding-bottom")
                .replace("px", "")) + parseInt(d.css("padding-top")
                .replace("px", "")) - this.sidebarPadding1;
        if (b) {
            $(".sidebar")
                .height(a);
            if (c) {
                this.showLoadingState(true)
            }
        } else {
            $(".sidebar")
                .animate({
                    height: a
                }, this.sidebarAnimationDuration, $.proxy(function () {
                    if (c) {
                        this.showLoadingState(true)
                    }
                }, this))
        } if (grid && grid.settings.fullWidth) {
            this.resizeGrid()
        }
    },
    resizeGrid: function () {
        var b, a = this.sidebarPadding2;
        b = $(".content")
            .width() - ($(".sidebar")
                .width() + a);
        grid.setWidth(b)
    },
    getPage: function (b, c, a) {
        if (!b) {
            if (!this.usePushState && location.hash.replace("#", "")) {
                b = location.hash.replace("#", "")
            } else {
                b = window.location.pathname
            }
        }
        return b
    },
    getFormURL: function () {
        var a = this.getURLParams();
        return a.formID ? navStorage.readVariable("form" + a.formID) : false
    },
    pagechange: function () {
        var b = this.getFormURL(),
            a = window.location.pathname + window.location.search;
        if (!this.isInitialLoad && b) {
            this.changePage(b, false, true)
        } else {
            if (!this.isInitialLoad) {
                this.changePage(a)
            } else {
                if (this.isInitialLoad && b && b != a) {
                    $(".innercontent")
                        .stop();
                    this.changePage(b, false, true)
                }
            }
        }
        this.isInitialLoad = false
    },
    hashchange: function () {
        var a = location.hash.replace("#", "");
        if (a) {
            this.changePage(a)
        } else {
            if (!this.isInitialLoad) {
                this.changePage(window.location.pathname + window.location.search)
            }
        }
        this.isInitialLoad = false
    },
    pushState: function (a) {
        if (this.usePushState) {
            history.pushState({}, "", a)
        }
    },
    changePageURL: function (a, b) {
        if (this.usePushState) {
            this.pushState(a);
            this.changePage(a, b)
        } else {
            location.hash = a
        }
        return false
    },
    changePage: function (d, g, a, f) {
        window.scrollTo(0, 0);
        this.currentURL = d;
        if (this.animateTransitions) {
            this.isAnimating = true
        }
        this.hideError();
        this.showLoadingState();
        if (d && d.indexOf("overview.action") == -1) {
            menu.selectMenuItemByPage(d, false, true)
        }
        this.animateContentOut(a);
        if (grid) {
            grid.destroy();
            grid = false;
            this.resizeSections(false, true)
        }
        if (!f) {
            var b = d;
            var c = "";
            if (d.indexOf("?") > -1) {
                var e = d.split("?");
                b = e[0];
                c = e[1]
            }
            $.post(b, c, $.proxy(function (i, h) {
                this.onPageLoaded(i, h, d)
            }, this))
                .error($.proxy(this.showError, this))
        } else {
            $.post(d.split("?")
                .shift(), this.getURLParams(d), $.proxy(function (i, h) {
                    this.onPageLoaded(i, h, d)
                }, this))
                .error($.proxy(this.showError, this))
        }
    },
    onPageLoaded: function (d, b, e) {
        var f = this.getFormURL();
        var g = this.getURLParams();
        var c = g.formResume ? g.formResume : false;
        if (f && c && e != f) {
            if (this.usePushState) {
                this.pagechange()
            } else {
                this.hashchange()
            }
        }
        if (e && this.currentURL && e != this.currentURL) {
            return false
        }
        if (d.indexOf('data-hideSideNav="true"') <= -1) {
            $(this.contentReference)
                .html('<div class="filler"></div>');
            $(".sidebar")
                .show()
        } else {
            $(this.contentReference)
                .html('<div class="fillerFull"></div>');
            $(".sidebar")
                .hide()
        }
        this.showLoadingState();
        var a = $("<div>")
            .html(d)
            .find(this.contentReference);
        if (a && a.length > 0) {
            $(this.contentReference)
                .replaceWith(a)
        }
        this.resizeSections(true);
        this.animateContentOut();
        document.title = d.substring(d.indexOf("<title>") + 7, d.indexOf("</title>"));
        if (!this.waitForAdditionalData) {
            this.animateContentIn()
        }
        if (b == "error" || !d) {
            return this.showError()
        }
        this.initializePage();
        this.prepareRetina()
    },
    onCustomLinkClicked: function (b) {
        var a;
        if (b.target.tagName == "SPAN") {
            a = $(b.target)
                .parent()
                .attr("href")
        } else {
            a = $(b.target)
                .attr("href")
        }
        this.changePageURL(a);
        return false
    },
    popup: function () {},
    getURLParams: function (a) {
        var b = {}, c;
        a = a || location.href;
        c = a.indexOf("?");
        if (c > -1) {
            $(a.slice(c + 1)
                .split("&"))
                .each(function () {
                    currentVar = this.split("=");
                    currentKey = currentVar[0];
                    currentVal = decodeURIComponent(currentVar[1].replace(/\+/g, " "));
                    if (currentKey in b) {
                        if (!$.isArray(b[currentKey])) {
                            b[currentKey] = [b[currentKey]]
                        }
                        b[currentKey].push(currentVal)
                    } else {
                        b[currentKey] = currentVal
                    }
                })
        }
        return b
    },
    getURLParam: function (b, a) {
        var c = this.getURLParams(a);
        return c[b] || false
    },
    appendFiltersToURL: function (b) {
        var c = navStorage.getCurrentFilters(),
            d = this.getURLParams(b),
            a;
        for (a in c) {
            if (d[a] != "" && !d[a]) {
                b += b.indexOf("?") > -1 ? "&" : "?";
                b += a + "=" + c[a]
            }
        }
        return b
    },
    prepareRetina: function () {
        if (this.useRetina) {
            if (!this.retina) {
                this.retina = new window.AC.Retina
            }
            this.retina.replace(document.body)
        }
    }
});
window.menuObject = Class.extend({
    animationDuration: 200,
    selectAnimationDuration: 100,
    initializeNav: function () {
        $(".topbar .topbar-select")
            .click($.proxy(this.toggleSelectAccount, this));
        $(".sidebar .sidebar-select")
            .click($.proxy(this.toggleSelectNav, this));
        $(".sidebar .select-dropdown li a")
            .click($.proxy(this.changeSelectNav, this));
        $(".sidebar > ul > li")
            .click($.proxy(this.setupPrimaryNav, this));
        $(".sidebar > ul > li .item-arrow")
            .click($.proxy(this.clickArrow, this));
        $(".sidebar ul ul li")
            .click($.proxy(this.setupSubNav, this));
        $("body")
            .mouseup($.proxy(this.mouseReleased, this));
        $(".portal-button, .toolbar-button")
            .mousedown(function () {
                $(this)
                    .addClass("click")
            })
    },
    mouseReleased: function (a) {
        $(".portal-button, .toolbar-button")
            .removeClass("click");
        if ($(a.target)
            .closest(".portal-select.active")
            .length == 0) {
            if ($(".portal-select.active")
                .attr("id") == "sidebar-select") {
                this.toggleSelectNav()
            } else {
                if ($(".portal-select.active")
                    .attr("id") == "topbar-select") {
                    this.toggleSelectAccount()
                }
            }
        }
    },
    setupPrimaryNav: function (b) {
        var a, c;
        a = $(b.target)
            .closest("li");
        a.addClass("selected")
            .find("ul")
            .slideDown(this.animationDuration);
        c = a.find("ul :first a");
        if (c.attr("href") && c.attr("href")
            .length > 1) {
            nav.changePageURL(c.attr("href"))
        }
        return false
    },
    setupSubNav: function (b) {
        var a = $(b.target)
            .closest("li")
            .find("a");
        this.selectMenuItemVisually(a);
        if (a.attr("href") && a.attr("href")
            .length > 1) {
            nav.changePageURL(a.attr("href"), true)
        }
        return false
    },
    clickArrow: function (b) {
        var a = $(b.target)
            .closest("li")
            .toggleClass("selected")
            .find("ul")
            .slideToggle(this.animationDuration)
            .end();
        navStorage.saveExpanded(a);
        return false
    },
    toggleSelectNav: function () {
        $(".sidebar .select-dropdown")
            .slideToggle(this.selectAnimationDuration);
        $(".sidebar .sidebar-select")
            .toggleClass("active");
        return false
    },
    changeSelectNav: function (c) {
        var b = $(c.target)
            .closest("a"),
            a = b.attr("href");
        if (a.substring(a.length - 4) == "-nav") {
            this.selectNavItem(b);
            visible = $("ul.nav:visible");
            if (visible.length > 0) {
                visible.slideUp(this.animationDuration, $.proxy(function () {
                    $("#" + a)
                        .slideDown(this.animationDuration);
                    nav.changePageURL($("#" + a)
                        .find("ul a:first")
                        .attr("href"))
                }, this))
            } else {
                $("#" + a)
                    .slideDown(this.animationDuration);
                nav.changePageURL($("#" + a)
                    .find("ul a:first")
                    .attr("href"))
            }
            return false
        } else {
            nav.changePageURL(b.attr("href"));
            return false
        }
    },
    selectNavItem: function (a) {
        $(".sidebar .section-title")
            .html(a.find("span")
                .html());
        $(".sidebar .section-icon")
            .removeClass()
            .addClass("section-icon " + a.attr("href"));
        $(".sidebar .select-dropdown li")
            .removeClass("current");
        a.parent()
            .addClass("current")
    },
    toggleSelectAccount: function (a) {
        $(".topbar .tooltip")
            .toggle();
        $(".topbar .topbar-select")
            .toggleClass("active");
        return false
    },
    selectMenuItem: function (b) {
        var a = b.closest("ul.nav")
            .show();
        $(".sidebar ul.nav:not(#" + a.attr("id") + ")")
            .hide();
        this.selectNavItem($(".sidebar .select-dropdown a[href=" + a.attr("id") + "]"));
        this.selectMenuItemVisually(b)
    },
    selectMenuItemVisually: function (a) {
        $(".sidebar ul ul li")
            .removeClass("selected");
        a.parent()
            .addClass("selected")
            .closest(".item")
            .addClass("selected")
            .find("ul")
            .slideDown(this.animationDuration, nav.updateAjaxDataSections)
    },
    selectMenuItemByPage: function (e, b, a, c) {
        var d;
        e = e || location.pathname;
        d = this.getMenuItemByURL(nav.getPage(e, b, a));
        if (d.length > 0) {
            this.selectMenuItem(d);
            navStorage.trackStates(c)
        }
    },
    selectMenuSection: function (a, b) {
        this.selectNavItem($(".sidebar .select-dropdown li." + a + "-nav a"));
        $("ul.nav:visible")
            .hide();
        $("#" + a + "-nav")
            .show();
        $("ul.nav:visible li." + b)
            .addClass("selected")
            .find("ul")
            .show()
    },
    generateSidebar: function (a) {
        $(a)
            .each(function () {
                var b, c;
                b = $(".sidebar .select-dropdown")
                    .after($('<ul class="nav" id="' + this.id + '">'))
                    .next("ul")
                    .prepend('<div class="horizontal-divider">');
                $(this.links)
                    .each(function () {
                        var d = $('<li class="item">')
                            .html('<a><div class="item-icon"></div><div class="title">' + this.title + '</div><div class="item-arrow"></div></a>');
                        if (!this.title) {
                            d.hide()
                        }
                        b.append(d);
                        c = d.append('<ul style="display: none;">')
                            .find("ul");
                        $(this.links)
                            .each(function () {
                                c.append($('<li class="subitem">')
                                    .html('<a href="' + this.link + '"><div class="subitem-icon"></div><div class="title">' + this.title + "</div></a>"))
                            })
                    })
            })
    },
    getSelectedURL: function () {
        return $(".sidebar ul ul li.selected a")
            .attr("href")
    },
    getFirstURLInMenu: function (a) {
        return a.find("ul :first a")
            .attr("href")
    },
    getCurrentMenuItems: function () {
        return this.getMenuItemByURL(location.pathname + location.search)
    },
    selectMenuItemVisuallyByURL: function (a) {
        this.selectMenuItemVisually(this.getMenuItemByURL(a))
    },
    expandMenuByURL: function (a) {
        this.getMenuItemByURL(a)
            .closest("ul")
            .show()
            .closest("li")
            .addClass("selected")
    },
    getMenuItemByURL: function (a) {
        return $('.sidebar a[href^="' + a + '"]')
            .first()
    }
});
window.gridObject = Class.extend({
    data: false,
    element: false,
    enabled: true,
    loaded: false,
    searchThrottleDuration: 50,
    searchThrottleDurationSlow: 200,
    selectedItems: false,
    settings: false,
    initialize: function (b) {
        var a = this;
        this.id = Math.random();
        this.settings = {
            datatype: "local",
            pager: "#paging",
            rowNum: 100000,
            height: "auto",
            forceFit: true,
            multiselect: true,
            cellLayout: 14,
            altRows: true,
            loadonce: true,
            hoverrows: true,
            viewrecords: true,
            recordpos: "left",
            disabled: false,
            fullWidth: true,
            allowSelections: true,
            preserveSelections: true,
            sortURLParam: true,
            resizeStop: $.proxy(this.onResizeStop, this),
            onSelectRow: $.proxy(this.onSelectRow, this),
            beforeSelectRow: $.proxy(this.beforeSelectRow, this),
            onSelectAll: $.proxy(this.onSelectAll, this),
            gridComplete: $.proxy(this.onGridUpdated, this),
            loadError: $.proxy(this.onLoadError, this),
            onCellSelect: $.proxy(this.onCellSelect, this),
            ondblClickRow: $.proxy(this.ondblClickRow, this),
            onPaging: $.proxy(this.onPaging, this),
            onSortCol: $.proxy(this.onSortCol, this)
        };
        $.extend(this.settings, b);
        this.settings.colNames = this.getColumnTitles();
        this.setDefaultSort();
        this.element = $(b.gridSection);
        this.initializeEvents();
        this.selectedItems = [];
        if (nav) {
            nav.showLoadingState();
            this.settings.url = nav.appendFiltersToURL(this.settings.url)
        }
        $.post(this.settings.url, $.proxy(function (c) {
            if (this.id != grid.id) {
                return false
            }
            this.data = c;
            if (this.data.resultCode != 0) {
                this.element.trigger("onError", this.data.userString);
                return false
            }
            this.element.trigger("onDataLoaded");
            if (this.settings.dataArrayField) {
                this.data = this.data[this.settings.dataArrayField]
            }
            $(this.data)
                .each($.proxy(function (d, e) {
                    if (this.data[d]) {
                        this.data[d].jqGridRowID = d + 1
                    }
                }, a));
            $($.proxy(function () {
                this.element.jqGrid(this.settings)
            }, a))
                .navGrid(this.settings.pager, {
                    edit: false,
                    add: false,
                    del: false
                });
            this.element.jqGrid("addRowData", "jqGridRowID", this.data);
            if (this.settings.disabled) {
                this.disable()
            }
            this.element.trigger("onGridInitiallyRendered");
            this.element.jqGrid()
                .trigger("reloadGrid")
        }, a), "json")
            .error($.proxy(function () {
                this.element.trigger("onError", arguments)
            }, a))
    },
    initializeEvents: function () {
        this.element.bind("onDataLoaded", $.proxy(this.onDataLoaded, this));
        this.element.bind("onGridUpdated", $.proxy(this.onGridUpdated, this));
        this.element.bind("onResizeStop", $.proxy(this.onResizeStop, this));
        this.element.bind("onSelectAll", $.proxy(this.onSelectAll, this));
        this.element.bind("onSelectRow", $.proxy(this.onSelectRow, this));
        this.element.bind("beforeSelectRow", $.proxy(this.beforeSelectRow, this));
        this.element.bind("onSortCol", $.proxy(this.onSortCol, this));
        this.element.bind("onGridInitiallyRendered", $.proxy(this.onGridInitiallyRendered, this));
        if (nav.resizeSections) {
            this.element.bind("onGridInitiallyRendered", $.proxy(nav.resizeSections, nav))
        }
        if (nav.showError) {
            this.element.bind("onError", $.proxy(nav.showError, nav))
        }
    },
    onDataLoaded: function () {},
    onGridInitiallyRendered: function () {
        if (!this.settings.allowSelections) {
            this.element.jqGrid()
                .hideCol("cb")
        }
    },
    onSelectRow: function (b, a) {
        if (!this.enabled) {
            this.element.resetSelection();
            return false
        }
        if (this.settings.preserveSelections) {
            if (a) {
                this.addItem(b)
            } else {
                this.removeItem(b)
            }
            $(".action")
                .toggleClass("disabled", this.selectedItems.length <= 0)
        }
    },
    beforeSelectRow: function (b, a) {
        return this.settings.allowSelections
    },
    onSelectAll: function (b, a) {
        if (!this.enabled) {
            this.element.resetSelection();
            return false
        }
        if (this.settings.preserveSelections) {
            this.selectedItems = [];
            if (a) {
                $(this.data)
                    .each($.proxy(function (c, d) {
                        this.addItem(c + 1)
                    }, this))
            }
            $(".action")
                .toggleClass("disabled", this.selectedItems.length <= 0)
        }
    },
    onGridUpdated: function () {
        if (this.defaultSelectedItems) {
            this.selectItems(this.defaultSelectedItems);
            this.defaultSelectedItems = false
        }
        this.loaded = true;
        if (this.settings.preserveSelections) {
            this.element.resetSelection();
            $(this.selectedItems)
                .each($.proxy(function (a, b) {
                    this.element.setSelection(b)
                }, this))
        }
        if (nav) {
            nav.hideLoadingState()
        }
    },
    onResizeStop: function () {
        var a = this.element.jqGrid("getGridParam", "colModel");
        $(a)
            .each(function (b, c) {
                c.widthOrg = c.width
            })
    },
    onSortCol: function (d, b, c) {
        var a;
        if (this.settings.sortURLParam && history.pushState) {
            a = window.location.pathname + "?sort=" + d + "%20" + c;
            params = nav.getURLParams();
            $(params)
                .each(function () {
                    if (this.length && this != "sort") {
                        a += "&" + this + "=" + params[this]
                    }
                });
            history.pushState({}, "", a)
        }
        if (nav) {
            nav.showLoadingState()
        }
    },
    onSearch: function (a) {
        this.throttle(function () {
            var b = a.target.value;
            if ((this.term && b != this.term) || (!this.term && b)) {
                if (nav) {
                    nav.showLoadingState()
                }
                setTimeout($.proxy(function () {
                    this.filterData(b)
                }, this), 1)
            }
        }, nav.isSlowBrowser ? this.searchThrottleDurationSlow : this.searchThrottleDuration)()
    },
    allowSelections: function () {
        this.settings.allowSelections = true;
        this.element.showCol("cb")
            .trigger("reloadGrid");
        if (nav.resizeGrid) {
            nav.resizeGrid()
        }
    },
    disallowSelections: function () {
        this.settings.allowSelections = false;
        this.selectItems([]);
        this.element.hideCol("cb")
            .trigger("reloadGrid");
        if (nav.resizeGrid) {
            nav.resizeGrid()
        }
    },
    addItem: function (a) {
        a = parseInt(a);
        if ($.inArray(a, this.selectedItems) < 0) {
            this.selectedItems.push(a)
        }
    },
    removeItem: function (a) {
        a = parseInt(a);
        this.selectedItems.splice(this.selectedItems.indexOf(a), 1)
    },
    setDefaultSelectedItems: function (a) {
        if (this.loaded) {
            this.selectItems(a)
        } else {
            this.defaultSelectedItems = a
        }
    },
    selectItems: function (a) {
        this.selectedItems = [];
        this.element.resetSelection();
        $(a)
            .each($.proxy(function (c, b) {
                $(this.data)
                    .each($.proxy(function (d, e) {
                        if (e[this.settings.dataIndexField] == b) {
                            this.addItem(d + 1);
                            this.element.setSelection(d + 1)
                        }
                    }, this))
            }, this))
    },
    getSelectedItems: function () {
        var a = [];
        $(this.selectedItems)
            .each($.proxy(function (b, c) {
                a.push(this.getDataIDForRow(c))
            }, this));
        return a.toString()
    },
    getDataIDForRow: function (a) {
        if (this.settings.dataIndexField) {
            return this.data[a - 1][this.settings.dataIndexField]
        } else {
            return a
        }
    },
    getDataItemForRow: function (a) {
        return this.data[a - 1]
    },
    getColumnTitles: function () {
        var a = [];
        $(this.settings.colModel)
            .each($.proxy(function (b, c) {
                a.push(c.title);
                if (!c.classes) {
                    this.settings.colModel[b].classes = "ui-ellipsis"
                }
            }, this));
        return a
    },
    setWidth: function (a) {
        this.element.setGridWidth(a)
    },
    setDefaultSort: function () {
        var a = nav.getURLParams();
        if (this.settings.sortURLParam && history.pushState && a.sort) {
            if (a.sort.indexOf("%20") > -1) {
                a.sort = a.sort.split("%20");
                this.settings.sortname = a.sort[0];
                this.settings.sortorder = a.sort[1]
            }
        }
    },
    enable: function () {
        if (this.element) {
            this.enabled = true;
            this.element.css("opacity", 1)
        }
    },
    disable: function () {
        if (this.element) {
            this.enabled = false;
            this.selectedItems = [];
            if (this.loaded) {
                this.element.resetSelection()
            }
            $(".action")
                .toggleClass("disabled", true);
            this.element.css("opacity", nav.config.loadingOpacity)
        }
    },
    destroy: function () {
        if (this.element) {
            this.element.stop()
                .unbind();
            this.element.GridDestroy()
        }
    },
    filterData: function (b) {
        var a, d, e, c, f;
        this.term = b.toLowerCase();
        a = [];
        $(this.data)
            .each($.proxy(function (g, h) {
                d = false;
                for (e in h) {
                    if (h[e]) {
                        c = h[e];
                        f = "";
                        $(this.settings.colModel)
                            .each(function (i, j) {
                                if (j.name == e) {
                                    if (j.formatter) {
                                        c = j.formatter(c)
                                    }
                                    f = c
                                }
                            });
                        if (f.toString()
                            .toLowerCase()
                            .indexOf(this.term) > -1) {
                            d = true
                        }
                    }
                }
                if (d) {
                    a.push(h)
                }
            }, this));
        this.selectedItems = [];
        this.element.clearGridData();
        this.element.addRowData("jqGridRowID", a);
        this.element.jqGrid()
            .trigger("reloadGrid");
        return a.length
    },
    formatDate: function (f) {
        var a, c, e, b, d;
        if (!f) {
            return ""
        }
        d = f.split("-");
        if (d.length < 3) {
            return f
        }
        a = {
            "01": "Jan",
            "02": "Feb",
            "03": "Mar",
            "04": "Apr",
            "05": "May",
            "06": "June",
            "07": "Jul",
            "08": "Aug",
            "09": "Sep",
            "10": "Oct",
            "11": "Nov",
            "12": "Dec"
        };
        c = d[0];
        e = a[d[1]];
        b = d[2].substring(0, 2);
        return e + " " + b + ", " + c
    },
    throttle: function (c, b) {
        var a = this,
            d = null;
        return function () {
            var e = arguments;
            clearTimeout(d);
            d = setTimeout(function () {
                c.apply(a, e)
            }, b)
        }
    }
});
window.grid = false;
window.formObject = Class.extend({
    animateTransitions: true,
    changeURL: false,
    curForm: false,
    curPageName: false,
    curURL: false,
    element: false,
    iframe: false,
    response: false,
    settings: false,
    steps: false,
    initialize: function (a) {
        if (this.settings && this.settings.preserveProgress && this.element) {
            this.element.dialog("open");
            return false
        }
        this.settings = {
            autoOpen: true,
            modal: true,
            width: 600,
            height: "auto",
            draggable: false,
            resizable: false,
            closeOnEscape: false,
            show: "fade",
            hide: "explode",
            close: $.proxy(this.onClose, this),
            loadingState: '<div class="loading"><img src="/assets/developerportal/images/spinner.gif"><br/>Loading...</div>',
            preserveProgress: false
        };
        $.extend(this.settings, a);
        if (!this.steps) {
            this.steps = {
                step1: {
                    url: window.location.pathname + location.hash
                }
            }
        }
        if (this.settings.pageElement) {
            this.element = $(this.settings.pageElement);
            for (step in this.steps) {
                if (this.steps[step].init) {
                    this.curPageName = step;
                    return this.onPageLoaded(this.steps[step].init)
                } else {
                    return this.onPageLoaded()
                }
            }
        } else {
            this.element = $("<div>")
                .html(this.settings.loadingState);
            this.element.dialog(this.settings);
            this.refresh()
        }
    },
    loadStep: function (a, b) {
        if (!b) {
            b = this.getInitByURL(a)
        }
        this.curURL = a;
        this.element.load(a, $.proxy(function () {
            this.onPageLoaded(b)
        }, this))
    },
    getPageName: function (a) {
        return this.getNextPage()
    },
    refresh: function (a) {
        var b, c;
        if (!a) {
            a = this.getPageName(this.response)
        }
        this.curPageName = a;
        if (a && this.steps[a] && this.steps[a].url) {
            b = this.steps[a].url;
            c = this.steps[a].init
        } else {
            b = this.settings.url;
            c = false
        }
        this.loadStep(b, c)
    },
    getNextPage: function () {
        var b = false,
            a = this.curPageName;
        for (step in this.steps) {
            if (b || !a) {
                a = step;
                b = false
            }
            if (step == this.curPageName) {
                b = true
            }
        }
        return a
    },
    getPreviousPage: function () {
        var c = false,
            a = this.curPageName,
            b;
        for (step in this.steps) {
            if (step == this.curPageName) {
                c = true
            }
            if (c) {
                a = b;
                c = false
            }
            b = step
        }
        return a
    },
    getInitByURL: function (a) {
        for (step in this.steps) {
            if (this.steps[step].url == a) {
                this.curPageName = step;
                return this.steps[step].init
            }
        }
        return false
    },
    animateContentOut: function () {
        if (this.animateTransitions) {
            nav.animateContentOut(true);
            nav.showLoadingState()
        }
    },
    animateContentIn: function () {
        if (this.animateTransitions && !nav.waitForAdditionalData) {
            $(".content")
                .removeClass("opaque");
            this.element.animate({
                opacity: 1
            }, nav.config.animationDuration);
            nav.hideLoadingState()
        }
    },
    setFormResponse: function (a) {
        if (a) {
            this.response = a;
            return true
        } else {
            this.response = this.iframe.contents();
            if (this.response.find(nav.contentReference)) {
                this.response = {
                    responseStatic: this.response.find("html")
                        .html(),
                    resultCode: 0
                };
                return true
            } else {
                this.response = this.iframe.contents()
                    .find("body");
                this.response = this.response.find("pre") ? this.response.find("pre")
                    .html() : this.response.html()
            }
        }
        try {
            if (!this.response) {
                throw "error"
            }
            this.response = $.parseJSON(this.response);
            return true
        } catch (b) {
            this.curForm.trigger("onError", "There was a problem processing the server response. Please try again.");
            return false
        }
    },
    validateForm: function (a) {
        form_valid = $(".validate:not([validated=true])", a)
            .length == 0;
        if (form_valid) {
            $(".form-error")
                .hide();
            nav.resizeSections()
        }
        return this.toggleForm(form_valid)
    },
    validateField: function (d, a, c) {
        var b = $(d);
        if (d.type == "radio" || d.type == "checkbox") {
            b = $("[input[name=" + d.name + "]:" + d.type)
        }
        b.attr("validated", a ? true : false);
        if (c) {
            $(".form-error." + d.name)
                .toggle(!a);
            nav.resizeSections()
        }
        return this.validateForm(b.closest("form"))
    },
    validateInitialState: function () {
        $(".validate:not(:checkbox)", this.element)
            .change();
        var b = {};
        var a = this;
        $('.validate[type="checkbox"]')
            .each(function () {
                var c = $(this)
                    .attr("name");
                b[c] = (b[c] || 0) + ($(this)
                    .is(":checked") ? 1 : 0)
            });
        $.each(b, function (d, c) {
            a.validateField($("input[name=" + d + '][type="checkbox"]:first'), c, true)
        });
        $(".form-error", this.element)
            .hide();
        nav.resizeSections()
    },
    toggleForm: function (a) {
        $(".submit", this.element)
            .toggleClass("disabled", !a);
        return a
    },
    initializeHiddenNavigation: function () {
        var b = nav.getURLParams(),
            a = navStorage.readVariable("form" + b.formID) || location.href,
            c = a.indexOf("?");
        if (c > -1) {
            $(a.slice(c + 1)
                .split("&"))
                .each($.proxy(function (d, h) {
                    var e = h.split("=")[0],
                        g = decodeURIComponent(h.split("=")[1].replace(/\+/g, " ")),
                        f = $("<input>")
                            .attr("type", "hidden")
                            .attr("name", e)
                            .val(g)
                            .addClass("autoField");
                    if (e != "formID" && $(":input[name=" + e + "]:not(.autoField)")
                        .length == 0) {
                        $("form", this.element)
                            .prepend(f)
                    }
                }, this))
        }
    },
    initializeDefaultValues: function () {
        params = nav.getURLParams(nav.getFormURL());
        fields = $('input[type="text"], textarea, select', this.element);
        checkboxes = $('input[type="checkbox"], input[type="radio"]', this.element);
        $.each(fields, function (a, b) {
            if (b.name in params) {
                $(b)
                    .val(params[b.name])
            }
        });
        $.each(checkboxes, function (a, b) {
            if (b.name in params) {
                if ($.isArray(params[b.name])) {
                    if ($.inArray(b.value, params[b.name]) > -1) {
                        $(b)
                            .attr("checked", true)
                    } else {
                        $(b)
                            .attr("checked", false)
                    }
                } else {
                    if (b.value == params[b.name]) {
                        $(b)
                            .attr("checked", true)
                    } else {
                        $(b)
                            .attr("checked", false)
                    }
                }
            }
        })
    },
    changePage: function (a) {
        var c, b;
        if (this.changeURL) {
            nav.changePageURL(a)
        } else {
            b = nav.getURLParams();
            b.formID = Math.floor(Math.random() * 100000000);
            a += (a.indexOf("?") <= 0 ? "?" : "&") + "formID=" + b.formID;
            navStorage.saveVariable("form" + b.formID, a, nav.config.formStorageExpiration);
            c = location.pathname + "?" + $.param(b);
            if (location.pathname + location.search != c) {
                nav.pushState(c)
            }
            nav.changePage(a)
        }
        return false
    },
    onPageLoaded: function (a) {
        if (a) {
            a()
        }
        if (!this.settings.pageElement) {
            this.element.dialog("option", "height", "auto")
        }
        this.animateContentIn();
        this.initializeHiddenNavigation();
        this.initializeDefaultValues();
        $(".continue", this.element)
            .click($.proxy(this.onNext, this));
        $(".back", this.element)
            .click($.proxy(this.onBack, this));
        $(".previous", this.element)
            .click($.proxy(this.onPrevious, this));
        $(".cancel", this.element)
            .click($.proxy(this.onCancel, this));
        $(".close", this.element)
            .click($.proxy(this.onCustomClose, this));
        $(".destroy", this.element)
            .click($.proxy(this.onCustomDestroy, this));
        $(".submit", this.element)
            .click(function () {
                $(this)
                    .closest("form")
                    .submit();
                return false
            });
        $("form", this.element)
            .submit($.proxy(this.onFormSubmission, this))
            .bind("onSubmitFinished", $.proxy(this.onFormSubmitFinished, this))
            .bind("onError", $.proxy(this.onError, this))
    },
    onNext: function (b) {
        this.animateContentOut();
        var a = $(b.target)
            .attr("href");
        if (a) {
            this.loadStep(a, false)
        } else {
            this.refresh(this.getNextPage())
        }
    },
    onPrevious: function (b) {
        this.animateContentOut();
        var a = $(b.target)
            .attr("href");
        if (a) {
            this.loadStep(a, false)
        } else {
            this.refresh(this.getPreviousPage())
        }
    },
    onBack: function (b) {
        var a = this.getBackLink($(b.target)
            .closest("a")
            .attr("href"), "");
        return this.changePage(a)
    },
    getBackLink: function (a, b) {
        var c = $(":hidden" + b, this.element)
            .serialize();
        if (c) {
            a += a.indexOf("?") > -1 ? "&" : "?";
            a += c
        }
        return a
    },
    onCancel: function (a) {
        if (!$(a.target)
            .closest("a")
            .attr("href")) {
            nav.changePageURL($("li.subitem.selected a")
                .attr("href"));
            return false
        } else {
            return true
        }
    },
    onFormSubmission: function (a) {
        if (!this.validateForm(a.target)) {
            return false
        }
        window.scrollTo(0, 0);
        this.animateContentOut();
        this.curForm = $(a.target);
        if (!this.curForm.attr("action")) {
            this.response = {
                resultCode: 0
            };
            this.curForm.trigger("onSubmitFinished");
            return false
        }
        return this.processFormRequest(a)
    },
    processFormRequest: function (a) {
        if (this.curForm.attr("method") == "get") {
            $.post(this.curForm.attr("action"), this.curForm.serialize(), $.proxy(function (b) {
                if (this.setFormResponse(b)) {
                    this.curForm.trigger("onSubmitFinished", arguments)
                }
            }, this));
            return false
        } else {
            this.curForm.attr("target", "wizardIframe");
            this.iframe = $('<iframe name="wizardIframe">')
                .hide()
                .appendTo("body");
            this.iframe.load($.proxy(function () {
                if (this.setFormResponse()) {
                    this.curForm.trigger("onSubmitFinished", arguments)
                }
            }, this))
        }
        return true
    },
    onFormSubmitFinished: function () {
        var a, b;
        if (this.iframe) {
            this.iframe.remove()
        }
        a = this.response.successURL || this.curForm.attr("successURL") || this.settings.successURL;
        if (this.response.resultCode != 0) {
            this.curForm.trigger("onError", this.response.userString)
        } else {
            if (this.response.responseStatic) {
                nav.onPageLoaded(this.response.responseStatic)
            } else {
                if (a) {
                    b = this.curForm.serialize();
                    if (b) {
                        if (a.indexOf("?") <= 0) {
                            a += "?"
                        }
                        a += b
                    }
                    this.changePage(a)
                } else {
                    this.refresh()
                }
            }
        }
    },
    onClose: function () {
        if (!this.settings.preserveProgress) {
            this.destroy()
        }
    },
    onCustomClose: function () {
        this.element.dialog("close")
    },
    onCustomDestroy: function () {
        this.destroy()
    },
    destroy: function () {
        if (this.element) {
            this.element.dialog("destroy")
                .remove()
        }
        this.element = false;
        this.curForm = false;
        this.curPageName = false;
        this.curURL = false
    },
    basicFormSubmission: function (a) {
        if (this.validateForm(a.target)) {
            $(".submit", this.element)
                .addClass("disabled");
            nav.showLoadingState();
            this.animateContentOut();
            return true
        }
        return false
    },
    onFormDataLoaded: function (a) {
        $(":input", this.element)
            .each($.proxy(function (b, c) {
                if (a[c.name]) {
                    if (c.type == "text" || c.type == "hidden" || c.type == "select-one") {
                        $(c)
                            .val(a[c.name])
                    } else {
                        if (c.value == a[c.name]) {
                            $(c)
                                .attr("checked", true)
                        }
                    }
                }
            }, this))
    },
    onError: function (b, a) {
        this.animateContentIn();
        if (this.response && this.response.validationMessages) {
            $(".form-error", this.element)
                .hide();
            $(this.response.validationMessages)
                .each(function () {
                    $(".form-error." + this.validationKey, this.element)
                        .html(this.validationUserMessage)
                        .show()
                });
            nav.resizeSections()
        }
        if (!this.response || !this.response.validationMessages) {
            a = a && a != "error" ? a.replace(/\\n/g, "<br/>") : $(".errorGenericMessage")
                .html();
            nav.popup(nav.config.popupWidth, "An unspecified error occurred.", a, "OK")
        }
    }
});
(function (a) {
    window.surveyFormObject = {
        init: function () {
            this.validateForm();
            a(".continueButton")
                .click(this.validateForm);
            a(".surveyForm")
                .submit(function () {
                    return (!a(".continueButton")
                        .hasClass("disabled"))
                });
            a("select.required, :checkbox")
                .change(function () {
                    surveyFormObject.validateForm()
                })
        },
        textboxCheckboxToggle: function (b, c) {
            jQuery("#" + c)
                .prop("checked", (b.value.length > 0))
        },
        validateForm: function (b) {
            a("[class*=required]")
                .each(function () {
                    surveyFormObject.validateField(a(this))
                });
            a(".continueButton")
                .toggleClass("disabled", a(".required:not(.validation-passed     )")
                    .length > 0);
            if (b) {
                a(".surveyForm")
                    .submit()
            }
        },
        validateField: function (c) {
            var b = false;
            if (c.is("ul")) {
                if (c.hasClass("type-checkbox") || c.hasClass("type-radio")) {
                    b = c.find("input:checked")
                        .length > 0
                } else {
                    if (c.hasClass("type-textfield")) {
                        c.find("input[type='text']")
                            .each(function () {
                                b = b || (a(this)
                                    .val()
                                    .length > 0)
                            })
                    } else {
                        console.log("Unable to find validation for required field: " + c.attr("id"))
                    }
                }
            } else {
                if (c.is("select")) {
                    b = (c.children("option:selected")
                        .length > 0 && c.children("option:selected")
                        .val()
                        .length > 0)
                } else {
                    if (c.is("div")) {
                        c.find("[class*=type-]")
                            .each(function () {
                                b = b || surveyFormObject.validateField(a(this))
                            })
                    } else {
                        console.log("Unable to find validation for required field: " + c.attr("id"))
                    }
                }
            }
            c.toggleClass("validation-passed", b);
            var d = a("#error" + c.attr("id"));
            if (d.length > 0) {
                d.toggle(!b)
            }
            return b
        }
    }
})(jQuery);
jQuery(document)
    .ready(function (a) {
        surveyFormObject.init()
    });
window.navPortalObject = navObject.extend({
    getPage: function (b, c, a) {
        b = this._super(b);
        if (!c) {
            $(nav.config.actionPrefixes)
                .each(function (d, e) {
                    b = b.replace(e + ".action", "List.action")
                })
        }
        if (b.indexOf(".action") > -1) {
            if (!a || b.indexOf("?") < 0) {
                b = b.substring(0, b.indexOf(".action") + 7)
            }
        }
        return b
    },
    get_popup_content: function (f, b, c, h, e, g, a) {
        var d = '<div class="icon ' + a + '"></div>';
        d += "<h4>" + f + "</h4>";
        d += "<p>" + b + "</p>";
        if (c || h) {
            d += '<div class="line"> </div>';
            d += '<div class="bottom-buttons">';
            if (h) {
                d += '<a class="button small ' + g + ' cancel"><span>' + h + "</span></a>"
            }
            if (c) {
                d += '<a class="button small ' + e + ' ok"><span>' + c + "</span></a>"
            }
            d += "</div>"
        }
        return d
    },
    popup: function (b, j, k, i, f, g, d, a, e) {
        var h, c;
        a = a || "warning";
        h = this.get_popup_content(j, k, i, f, g, d, a);
        c = $("<div>")
            .html(h)
            .dialog({
                autoOpen: true,
                modal: !e,
                width: b,
                height: "auto",
                draggable: false,
                resizable: false,
                closeOnEscape: true,
                show: "fade",
                hide: "fade",
                dialogClass: "standard-dialog"
            });
        c.find(".cancel, .ok")
            .click(function () {
                c.dialog("close");
                return false
            })
            .mousedown(function () {
                $(this)
                    .addClass("click")
            });
        return c
    },
    mark_popup_as_loading: function (a) {
        a.find(".ok")
            .addClass("disabled");
        a.find("p")
            .css("text-align", "center")
            .html('<img src="/assets/developerportal/images/spinner.gif">')
    },
    tooltip: function (c, g, b) {
        var a, f, e, d;
        $(c)
            .click($.proxy(function (h) {
                if ($("#" + g)
                    .length > 0) {
                    this.tooltip_remove(g)
                } else {
                    f = '<div class="top left corner"></div><div class="top edge"><div class="top right corner"></div></div><div class="left edge"></div><div class="tooltip-content"><div class="content-wrapper">';
                    f += b;
                    f += '</div><div class="right edge"></div></div><div class="bottom left corner"></div><div class="bottom edge"><a class="close-button"></a><div class="bottom right corner"></div></div>';
                    a = $('<div class="tooltip bottom-pointer" id="' + g + '" style="display: none;">')
                        .html(f);
                    $("body")
                        .prepend(a);
                    e = $(h.target)
                        .offset()
                        .left - (a.width() / 2) + ($(h.target)
                            .width() / 2);
                    d = $(h.target)
                        .offset()
                        .top - a.height();
                    $("#" + g)
                        .css("left", e)
                        .css("top", d)
                        .fadeIn(nav.config.animationDuration)
                        .find(".close-button")
                        .click($.proxy(function (i) {
                            this.tooltip_remove($(i.target)
                                .closest(".tooltip")
                                .attr("id"))
                        }, this))
                }
                return false
            }, this))
    },
    tooltip_remove: function (a) {
        $("#" + a)
            .fadeOut(nav.config.animationDuration, function () {
                $(this)
                    .remove()
            })
    },
    show_delete_popup: function (e, b, d, c, f) {
        var g = $(e),
            a;
        f = f || "Delete";
        a = this.popup(b, g.attr("title"), g.html(), f, "Cancel", "red");
        d += this.getSSUVParameter();
        a.find(".ok")
            .click($.proxy(function () {
                this.animateContentOut();
                this.showLoadingState();
                $.post(d, $.proxy(function (h) {
                    this.hideLoadingState();
                    if (h.resultCode != 0) {
                        this.showError(false, h.userString);
                        return false
                    }
                    this.changePageURL(c)
                }, this));
                return false
            }, this));
        return false
    },
    show_enable_popup: function (f, d, a, e, c) {
        var g = $(f),
            b;
        c = c || "Enable";
        b = this.popup(d, g.attr("title"), g.html(), c, "Cancel", "blue");
        a += this.getSSUVParameter();
        b.find(".ok")
            .click($.proxy(function () {
                this.animateContentOut();
                this.showLoadingState();
                $.post(a, $.proxy(function (h) {
                    this.hideLoadingState();
                    if (h.resultCode != 0) {
                        this.showError(false, h.userString);
                        return false
                    }
                    this.changePageURL(e)
                }, this));
                return false
            }, this));
        return false
    },
    show_confirmation_popup: function (g, c, e, d, a) {
        var f = $(g),
            b;
        a = a || "OK";
        b = this.popup(c, f.attr("title"), f.html(), a, "Cancel", "green");
        b.find(".ok")
            .click(function () {
                return nav.do_confirmation_request(e, d)
            });
        return false
    },
    getSSUVParameter: function () {
        var b = "adssuv-value";
        var a = $.cookie("adssuv");
        return "&" + b + "=" + a
    },
    do_confirmation_request: function (b, a) {
        this.animateContentOut();
        this.showLoadingState();
        window.scrollTo(0, 0);
        b += this.getSSUVParameter();
        $.post(b, $.proxy(function (c) {
            this.hideLoadingState();
            if (c.resultCode != 0) {
                this.showError(false, c.userString);
                return false
            }
            this.changePageURL(a)
        }, this));
        return false
    },
    requireCheckboxConfirmation: function (c) {
        var d = c.data.yesValue || "yes",
            b = c.data.noValue || "no",
            a = c.data.width || nav.config.popupWidth,
            e = c.data.confirmation;
        if ($(c.target)
            .is(":checked")) {
            c.data.actionURL += d;
            e = c.data.enableConfirmation || e
        } else {
            c.data.actionURL += b;
            e = c.data.disableConfirmation || e
        } if (e) {
            return nav.show_confirmation_popup(e, a, c.data.actionURL, c.data.successURL)
        } else {
            return nav.do_confirmation_request(c.data.actionURL, c.data.successURL)
        }
    },
    updateAjaxDataSections: function () {
        $("li.subitem:visible .loadServerData")
            .each(function () {
                var a = $(this);
                $.post(a.attr("href"), function (b) {
                    b = b[a.attr("data-field")];
                    a.find(".data")
                        .html(b);
                    a.toggle(parseInt(b) > 0)
                }, "json")
            })
    }
});
if (!window.nav) {
    window.nav = new navPortalObject;
    window.menu = new menuObject;
    window.navStorage = new navigationStorageObject;
    $(document)
        .ready(function () {
            nav.initialize()
        })
}
$(document)
    .ready(function () {
        $(".toolbar-button")
            .attr("role", "button")
            .attr("tabindex", "0");
        var c = $(".topbar .help")
            .parent("a"),
            b, d, a;
        c.click(function (f) {
            f.preventDefault();
            b = f.currentTarget.pathname;
            d = "dev_help";
            a = "width=660,height=660,toolbar=0,location=0,status=1,menubar=0,scrollbars=0,resizable=0,directories=0";
            window.open(b, d, a)
        })
    });
window.portalFormObject = formObject.extend({
    init: function () {
        this.initialize({
            pageElement: ".innercontent"
        })
    },
    validateRequired: function (b, a) {
        this.validateCustomFormat(b, /^(.+)*$/, a)
    },
    validateAlphaNumeric: function (b, a) {
        this.validateCustomFormat(b, /^([A-Za-z0-9]+)*$/, a)
    },
    validateAlphaNumericWithSpace: function (b, a) {
        this.validateCustomFormat(b, /^([A-Za-z0-9 ]+)*$/, a)
    },
    validateIdentifier: function (b, a) {
        this.validateCustomFormat(b, /^([A-Za-z0-9.-]+)*?$/, a)
    },
    validateWildcardIdentifier: function (b, a) {
        this.validateCustomFormat(b, /^(([A-Za-z0-9.-]+)*\*)?$/, a)
    },
    validateCustomFormat: function (e, c, b) {
        var d = $.trim($(b.target)
            .val()),
            a = d && d.match(c);
        this.validateField(b.target, a, e)
    },
    validateNumChars: function (d, b) {
        var c = $.trim($(b.target)
            .val()),
            a = c.length >= b.data.min && c.length <= b.data.max;
        this.validateField(b.target, a, d)
    },
    validateCheckboxes: function (c, b) {
        var a = $("input[name=" + b.target.name + "]:checked")
            .length;
        this.validateField(b.target, a, c)
    },
    addTextFieldValidator: function (b, a) {
        b.change($.proxy(a, this, true));
        b.keyup($.proxy(a, this, false))
    },
    changeFileUpload: function (a) {
        var b = $(a.target)
            .closest("div");
        b.find(".uploadPlaceholderText")
            .val(a.target.value.replace("C:\\fakepath\\", ""));
        b.find(".uploadPlaceholderIcon")
            .show()
    },
    processFormRequest: function (d) {
        var c = "adssuv-value";
        var a = $.cookie("adssuv");
        var b = $("<input>")
            .attr("type", "hidden")
            .attr("name", c)
            .val(a);
        if (this.curForm.find("input[name=" + c + "]")
            .length > 0) {
            this.curForm.find("input[name=" + c + "]")
                .replaceWith($(b))
        } else {
            this.curForm.append($(b))
        }
        return this._super(d)
    }
});
window.portalGridObject = gridObject.extend({
    detailsAnimationDuration: 200,
    itemIndex: "displayId",
    init: function () {
        nav.animateContentOut()
    },
    beforeSelectRow: function (b, a) {
        if (!this.settings.allowSelections) {
            this.toggleDetails(b)
        }
        return this._super(b, a)
    },
    onDataLoaded: function () {
        var a = this.settings.dataArrayField ? this.data[this.settings.dataArrayField] : this.data;
        var b = parseInt(a.length);
        if (b == 0) {
            document.location = document.URL.replace("List", "Landing")
                .split("?")
                .shift()
        } else {
            $(".gridCount")
                .text(b);
            if (b <= 0) {
                $(".content-toolbar .edit")
                    .addClass("disabled")
            }
        }
        this._super()
    },
    onGridInitiallyRendered: function () {
        $(".content-titlebar .search-tools input")
            .attr("disabled", false);
        this.initializeToolbar();
        nav.waitForAdditionalData = false;
        nav.animateContentIn();
        this._super()
    },
    filterData: function (b) {
        var a = this._super(b);
        $(".content-titlebar .search-tools div.text")
            .html(a + " match" + (a != 1 ? "es" : ""))
    },
    editIcon: function (a) {
        if (!$(a.target)
            .hasClass("active") && !$(a.target)
            .hasClass("disabled")) {
            if ($(".content-toolbar .search")
                .hasClass("active")) {
                $(".content-titlebar .search-tools .cancel-button")
                    .click()
            }
            $(a.target)
                .addClass("active");
            $(".content-toolbar span")
                .hide();
            $(".content-toolbar .toolbar-heading-edit")
                .show();
            $(".content-titlebar .title")
                .slideUp(this.detailsAnimationDuration);
            $(".content-titlebar .edit-tools")
                .slideDown(this.detailsAnimationDuration);
            this.allowSelections();
            $(".content-titlebar .edit-tools .cancel-button")
                .click($.proxy(function (b) {
                    $(".content-toolbar span")
                        .hide();
                    $(".content-toolbar .toolbar-heading-all")
                        .show();
                    $(".content-toolbar .edit")
                        .removeClass("active");
                    $(".content-titlebar .title")
                        .slideDown(this.detailsAnimationDuration);
                    $(".content-titlebar .edit-tools")
                        .slideUp(this.detailsAnimationDuration);
                    $(b.target)
                        .unbind("click");
                    $(".content-titlebar .edit-tools .remove-button")
                        .addClass("disabled");
                    this.disallowSelections()
                }, this));
            $(".content-titlebar .edit-tools .remove-button")
                .click($.proxy(function (c) {
                    var b = $(c.target)
                        .closest("a");
                    if (!b.hasClass("disabled")) {
                        nav.changePage(b.attr("href") + this.getSelectedItems(), false, false, true)
                    }
                    return false
                }, this))
        }
        return false
    },
    searchIcon: function (a) {
        if (!$(a.target)
            .hasClass("active") && !$(a.target)
            .hasClass("disabled")) {
            if ($(".content-toolbar .edit")
                .hasClass("active")) {
                $(".content-titlebar .edit-tools .cancel-button")
                    .click()
            }
            $(a.target)
                .addClass("active");
            $(".content-toolbar span")
                .hide();
            $(".content-toolbar .toolbar-heading-search")
                .show();
            $(".content-titlebar .search-tools div.text")
                .html("");
            $(".content-titlebar .title")
                .slideUp(this.detailsAnimationDuration);
            $(".content-titlebar .search-tools")
                .slideDown(this.detailsAnimationDuration);
            $(".content-titlebar .search-tools input")
                .focus();
            $(".content-titlebar .search-tools .cancel-button")
                .click(function (b) {
                    $(".content-toolbar span")
                        .hide();
                    $(".content-toolbar .toolbar-heading-all")
                        .show();
                    $(".content-titlebar .search-tools input")
                        .val("")
                        .change();
                    $(".content-toolbar .search")
                        .removeClass("active");
                    $(".content-titlebar .title")
                        .slideDown(this.detailsAnimationDuration);
                    $(".content-titlebar .search-tools")
                        .slideUp(this.detailsAnimationDuration);
                    $(this)
                        .unbind("click");
                    $(".content-titlebar .search-tools input")
                        .unbind("keyup change mouseup paste");
                    b.stopImmediatePropagation()
                });
            $(".content-titlebar .search-tools input")
                .bind("keyup change mouseup paste", $.proxy(this.onSearch, this))
                .keyup(function (b) {
                    if (b.keyCode == 27) {
                        $(".content-titlebar .search-tools .cancel-button")
                            .click()
                    }
                    b.stopImmediatePropagation();
                    return false
                })
        }
        return false
    },
    detailsBlock: function (a) {
        var b = $(".row-details-block")
            .clone();
        return this.processDetailsBlock(b, a)
            .html()
    },
    processDetailsBlock: function (b, a) {
        for (variable in a) {
            b.find(".data." + variable)
                .text(a[variable])
        }
        return b
    },
    showDeleteConfirmationMessage: function (a) {
        return nav.show_delete_popup(".removeConfirmationMessage", nav.config.popupWidth, a, this.listUrl)
    },
    toggleDetails: function (b) {
        var a = this.data[b - 1],
            c = a[this.itemIndex];
        if ($("tr#" + b)
            .hasClass("expanded")) {
            this.hideDetailsSection(b, a)
        } else {
            this.showDetailsSection(b, a, c)
        }
    },
    hideDetailsSection: function (b, a) {
        $("tr#" + b)
            .removeClass("expanded")
            .next("tr")
            .find(".row-details")
            .slideUp(this.detailsAnimationDuration, function () {
                nav.resizeSections();
                $(this)
                    .remove()
            })
    },
    showDetailsSection: function (c, b, d) {
        $("tr.expanded")
            .removeClass("expanded");
        $("tr .row-details")
            .slideUp(this.detailsAnimationDuration, function () {
                $(this)
                    .remove()
            });
        $("tr#" + c)
            .addClass("expanded");
        if ($("tr#" + c)
            .next("tr")
            .find(".row-details")
            .length == 0) {
            $("tr#" + c)
                .after('<tr role="row"><td colspan="' + this.settings.colModel.length + '" role="gridcell">' + this.detailsBlock(b) + "</tr></td>")
        }
        var a = $("tr#" + c)
            .next("tr")
            .find(".row-details")
            .slideDown(this.detailsAnimationDuration, function () {
                nav.resizeSections()
            });
        a.find(".edit-button:not(.disabled)")
            .click(function () {
                return nav.changePageURL(this.href + d)
            });
        a.find(".enable-button:not(.disabled)")
            .click($.proxy(function (f) {
                var e = $(f.target)
                    .closest("a");
                return this.showEnableConfirmationMessage(e.attr("href") + d)
            }, this));
        a.find(".remove-button:not(.disabled)")
            .click($.proxy(function (f) {
                var e = $(f.target)
                    .closest("a");
                return this.showDeleteConfirmationMessage(e.attr("href") + d)
            }, this));
        $(".button.small")
            .mousedown(function () {
                $(this)
                    .addClass("click")
            });
        return a
    },
    initializeToolbar: function () {
        $(".content-toolbar .edit")
            .click($.proxy(grid.editIcon, grid));
        $(".content-toolbar .search")
            .click($.proxy(grid.searchIcon, grid));
        if (location.href.indexOf("?tab=edit") > -1) {
            $(".content-toolbar .edit")
                .click()
        } else {
            if (location.href.indexOf("?tab=search") > -1) {
                $(".content-toolbar .search")
                    .click()
            }
        }
    }
});

