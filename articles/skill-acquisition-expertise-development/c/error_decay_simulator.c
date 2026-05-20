#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
static double u(){ return (double)rand()/(double)RAND_MAX; }
static double ur(double a,double b){ return a+(b-a)*u(); }
int main(int argc,char**argv){
    int n=argc>1?atoi(argv[1]):10000; srand((unsigned)time(NULL));
    double es=0, as=0, rts=0;
    for(int i=0;i<n;i++){
        double s=ur(1,12), p=ur(0,10), f=ur(0,10), d=ur(0,10);
        double lambda=0.06+0.012*p+0.008*f;
        double e=(0.70+0.02*d)*exp(-lambda*s); if(e<0)e=0; if(e>1)e=1;
        double a=1-e; double rt=3500*pow(s,-0.42)+650+30*d-45*f; if(rt<150)rt=150;
        es+=e; as+=a; rts+=rt;
    }
    printf("Trials: %d\nMean error: %.3f\nMean accuracy: %.3f\nMean RT: %.3f ms\n", n, es/n, as/n, rts/n);
    return 0;
}
