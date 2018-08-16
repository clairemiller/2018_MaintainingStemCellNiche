#include "FlatBaseMembraneForce.hpp"


template<unsigned DIM>
FlatBaseMembraneForce<DIM>::FlatBaseMembraneForce(unsigned verticalDirection)
    : AbstractUndulatingBaseMembraneForce<DIM>(verticalDirection)
{
}

template<unsigned DIM>
FlatBaseMembraneForce<DIM>::~FlatBaseMembraneForce()
{
}

template<unsigned DIM>
double FlatBaseMembraneForce<DIM>::BaseShapeFunction(c_vector<double,DIM> p)
{
    return(0.0);
}

template<unsigned DIM>
c_vector<double,DIM> FlatBaseMembraneForce<DIM>::CalculateDerivativesAtPoint(c_vector<double,DIM> p)
{
    c_vector<double, DIM> deriv = zero_vector<double>(DIM);
    deriv[this->mVert] = 1.0;
    return(deriv);
}

template<unsigned DIM>
void FlatBaseMembraneForce<DIM>::OutputForceParameters(out_stream& rParamsFile)
{
    AbstractUndulatingBaseMembraneForce<DIM>::OutputForceParameters(rParamsFile);
}

template<unsigned DIM>
void FlatBaseMembraneForce<DIM>::WriteDataToVisualizerSetupFile(out_stream& pVizSetupFile)
{
	AbstractUndulatingBaseMembraneForce<DIM>::WriteDataToVisualizerSetupFile(pVizSetupFile);
}


// Explicit instantiation
template class FlatBaseMembraneForce<1>;
template class FlatBaseMembraneForce<2>;
template class FlatBaseMembraneForce<3>;

#include "SerializationExportWrapperForCpp.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(FlatBaseMembraneForce)