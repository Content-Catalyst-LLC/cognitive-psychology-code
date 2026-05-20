#include <cmath>
#include <fstream>
#include <iostream>
#include <random>
double logistic(double x){ if(x>40) return 1; if(x<-40) return 0; return 1/(1+std::exp(-x)); }
int main(int argc,char**argv){
    std::string outpath=argc>1?argv[1]:"../outputs/cpp_deliberate_practice_transfer.csv";
    std::mt19937 rng(42); std::uniform_real_distribution<double> u(0,1); std::normal_distribution<double> z(0,1);
    std::ofstream out(outpath); out<<"trial,condition,session,practice_quality,feedback_quality,difficulty,accuracy,transfer_score,automaticity_score\n";
    double accs=0, trs=0; int n=5000;
    for(int t=1;t<=n;t++){
        bool deliberate=u(rng)<0.45, high_feedback=u(rng)<0.50;
        std::string cond=deliberate?"deliberate_practice":(high_feedback?"high_feedback":"control");
        double s=1+11*u(rng), p=deliberate?7+3*u(rng):3+5*u(rng), f=high_feedback?7+3*u(rng):2+5*u(rng), d=3+6*u(rng);
        double chunk=std::clamp(2+0.45*s+0.35*p+0.4*z(rng),0.0,10.0), pat=std::clamp(2+0.40*s+0.30*f+0.4*z(rng),0.0,10.0);
        double acc=logistic(-1+0.22*s+0.22*p+0.18*f+0.18*chunk+0.18*pat-0.25*d+0.15*z(rng));
        double tr=std::clamp(30+12*acc+3*p+2.2*f+2.8*pat-1.8*d+4*deliberate+5*z(rng),0.0,100.0);
        double aut=std::clamp(1+3.5*acc+0.35*chunk+0.32*pat-0.10*d+0.6*z(rng),0.0,10.0);
        accs+=acc; trs+=tr; out<<t<<","<<cond<<","<<s<<","<<p<<","<<f<<","<<d<<","<<acc<<","<<tr<<","<<aut<<"\n";
    }
    std::cout<<"Wrote "<<outpath<<"\nMean accuracy "<<accs/n<<"\nMean transfer "<<trs/n<<"\n";
}
