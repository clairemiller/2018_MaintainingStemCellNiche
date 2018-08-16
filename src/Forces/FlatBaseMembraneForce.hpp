#ifndef FLATBASEMEMBRANEFORCE_HPP_
#define FLATBASEMEMBRANEFORCE_HPP_

#include "AbstractUndulatingBaseMembraneForce.hpp"

#include "ChasteSerialization.hpp"
#include <boost/serialization/base_object.hpp>


template<unsigned DIM>
class FlatBaseMembraneForce : public AbstractUndulatingBaseMembraneForce<DIM>
{
private:
	// Add archiving functions
	friend class boost::serialization::access;
	friend class TestUndulatingBaseMembraneForce;
	
	template<class Archive>
	void serialize(Archive & archive, const unsigned int version )
	{
		archive & boost::serialization::base_object<AbstractUndulatingBaseMembraneForce<DIM> >(*this);
	}
public:
	/**
	 * Constructor
	 & @param verticalDirection the 'up' direction
	 */
	FlatBaseMembraneForce(unsigned verticalDirection = DIM-1);

	/**
	 * Default deconstructor
	*/
	virtual ~FlatBaseMembraneForce();

	/** 
	 * A function for the membrane shape
	 * @param p a reference to a x,y(,z) location to determine the appropriate height given a point location
	*/
	virtual double BaseShapeFunction(c_vector<double,DIM> p);

	/**
	 * Calculates the unit tangent vector to the membrane at a given point
	 * @param the point
	 */
	virtual c_vector<double,DIM> CalculateDerivativesAtPoint(c_vector<double,DIM> p);	

	/**
     * Outputs force parameters to file.
     * @param rParamsFile the file stream to which the parameters are output
     */
	virtual void OutputForceParameters(out_stream& rParamsFile);

	/**
     * Write any data necessary to a visualization setup file.
     * Used by AbstractCellBasedSimulation::WriteVisualizerSetupFile().
     * 
     * @param pVizSetupFile a visualization setup file
     */
	virtual void WriteDataToVisualizerSetupFile(out_stream& pVizSetupFile);
};

#include "SerializationExportWrapper.hpp"
EXPORT_TEMPLATE_CLASS_SAME_DIMS(FlatBaseMembraneForce)

#endif /*FLATBASEMEMBRANEFORCE_HPP_*/
