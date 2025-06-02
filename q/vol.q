/ ----------------------------------------------------------------------------------------
/ define functions which access global tables at the root level
/ ----------------------------------------------------------------------------------------
/ symbols: retrieve information on US symbols trading given a set of dates
/  median: calculate median fraction traded per second given times to omit,symbol,dates
/ ----------------------------------------------------------------------------------------
.vol.symbols:{[d]
 select tradedays:count i,avgtrades:avg n,exclude:date where a>count[d]-3 by get symbol
   from update rank a by symbol
   from select sum n,a:sum notional by date,symbol from us.volume where date in d}

.vol.median:{[t;s;d]
 update v%sum v from select med v by time
   from update v%sum v by date
   from select date,time,v:volume from us.volume where date in d,symbol=s,not time in t}

\d .vol

medians:{[n;s;t;d]{x . y}[median t]peach exec first'[(s;d)] by symbol from select symbol,s:symbol,d:d except/:exclude from s where avgtrades>=n}
seconds:{a+til"j"$x[1]-a:first x:"v"$x}
expand:{[x;m] a:$[-14h=type x;seconds .sys.session x;x]; k:([]time:a); 0^$[type get m; k#m; k#/:m]}
smooth:{[p;m]update s:sum[v]%count i by p from update p:1|p&ceiling p*sums v from m}
