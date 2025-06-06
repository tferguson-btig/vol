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

/ ----------------------------------------------------------------------------------------
/ medians: median fractions of volume per second for symbols w'enough trades over range
/ seconds: return all seconds in market session given start & end, e.g. 09:30 16:00
/  expand: expand median fractions of volume to all seconds given, zero-filled
/  smooth: sum fraction of volume per pctile, assign "smoothed" fraction to each pctile
/ minutes: return volume fractions summed per minute for single stock or dictionary
/ ----------------------------------------------------------------------------------------
medians:{[n;s;t;d]{x . y}[median t]peach exec first'[(s;d)] by symbol from select symbol,s:symbol,d:d except/:exclude from s where avgtrades>=n}
seconds:{a+til"j"$x[1]-a:first x:"v"$x}
expand:{[x;m] a:$[-14h=type x;seconds .sys.session x;x]; k:([]time:a); 0^$[type get m; k#m; k#/:m]}
smooth:{[p;m]update s:sum[v]%count i by p from update p:1|p&ceiling p*sums v from m}
minutes:{get exec sum s by time.minute from x}

/ -----------------------------------------------------------------------------------------
/ cluster: given volume fractions x,centroids y, return grouping at minimum distance
/  center: given groupings, return centroid from each grouping
/   kinit: initial grouping formed by random selection across k, return resulting centroids
/   ksort: sort groupings in descending order by number of members
/    krun: kmeans clustering given map x of symbol->volume fractions & k clusters
/   kruns: run kmeans clustering n times, return groupings in order of frequency
/  ktable: summarize n runs of kmeans clustering: occurence, group counts & first,last sym
/ -----------------------------------------------------------------------------------------
cluster:{get group flip[r]?'min r:{x wsum x}''[x-\:/:y]}
center:{avg'[x cluster[x]y]} 
kinit:{[x;k]avg'[x get key[x]group count[x]?k]}
ksort:{x idesc count each x}
krun:{[x;k]ksort cluster[x]center[x]/[kinit[x;k]]}
kruns:{[x;k;n]desc count each group krun[x]peach n#k}
ktable:{([]occurence:get x; counts:count''[key x]; ranges:{`$"-"sv string(first x;last x)}''[key x])}
